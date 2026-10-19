import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_api.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/data/models/user_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileApi extends Mock implements ProfileApi;

void main() {
  late ProfileRemoteDataSource dataSource;
  late MockProfileApi mockProfileApi;

  setUp(() {
    mockProfileApi = MockProfileApi();
    dataSource = ProfileRemoteDataSource(mockProfileApi);
  });

  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  final tError = DioException(requestOptions: RequestOptions(path: '/'));

  group('getUser', () {
    test(
      '''
      GIVEN a signed in user
      WHEN the user is fetched
      THEN the user model from the API is returned''',
      () async {
        // given
        final tUserResponseModel = UserResponseModel(
          id: tUserId,
          email: 'test@example.com',
        );
        when(() => mockProfileApi.getUser())
            .thenAnswer((_) async => tUserResponseModel);
        // when
        final result = await dataSource.getUser();
        // then
        expect(result, same(tUserResponseModel));
        verify(() => mockProfileApi.getUser()).called(1);
        verifyNoMoreInteractions(mockProfileApi);
      },
    );

    test(
      '''
      GIVEN the device is offline
      WHEN the user is fetched
      THEN the connection error from the API is thrown as a server failure
      AND its cause is the DioException from the API''',
      () async {
        // given
        when(() => mockProfileApi.getUser()).thenThrow(tError);
        // when
        final result = dataSource.getUser();
        // then
        await expectLater(result, throwsA(ServerFailure(tError)));
      },
    );
  });

  group('getProfile', () {
    test(
      '''
      GIVEN the user has a profile row
      WHEN the profile of the user is fetched by the user id
      THEN the profile model from the API is returned
      AND the API was asked for the profile whose id equals the user id,
          using PostgREST's "eq." filter''',
      () async {
        // given
        final tProfileResponseModel = ProfileResponseModel(
          id: tUserId,
          name: 'Test User',
          createdAt: DateTime.utc(2026, 1, 1, 10),
        );
        when(() => mockProfileApi.getProfile(any()))
            .thenAnswer((_) async => tProfileResponseModel);
        // when
        final result = await dataSource.getProfile(tUserId);
        // then
        expect(result, same(tProfileResponseModel));
        verify(() => mockProfileApi.getProfile('eq.$tUserId')).called(1);
        verifyNoMoreInteractions(mockProfileApi);
      },
    );

    test(
      '''
      GIVEN the user has no profile row
      WHEN the profile is fetched
      THEN the error from the API is thrown as a server failure
      AND its cause is the DioException from the API''',
      () async {
        // given
        when(() => mockProfileApi.getProfile(any())).thenThrow(tError);
        // when
        final result = dataSource.getProfile(tUserId);
        // then
        await expectLater(result, throwsA(ServerFailure(tError)));
      },
    );
  });
}
