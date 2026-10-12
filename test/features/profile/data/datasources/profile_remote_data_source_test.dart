import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_api.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileApi extends Mock implements ProfileApi {}

void main() {
  late ProfileRemoteDataSource dataSource;
  late MockProfileApi mockProfileApi;

  setUp(() {
    mockProfileApi = MockProfileApi();
    dataSource = ProfileRemoteDataSource(mockProfileApi);
  });

  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  final tProfileResponseModel = ProfileResponseModel(
    name: 'Test User',
    createdAt: DateTime.utc(2026, 1, 1, 10),
  );

  group('getProfile', () {
    test(
      '''
      GIVEN the API answers with a profile
      WHEN getProfile is called with the id of a user
      THEN the API is asked exactly once for the profile
           whose id equals that user id, written as the "eq." filter
      AND the profile of the API is returned''',
      () async {
        // given
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
      GIVEN the API fails with a DioException
      WHEN getProfile is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        final tDioException = DioException(
          requestOptions: RequestOptions(path: '/rest/v1/profiles'),
          type: .connectionError,
        );
        when(() => mockProfileApi.getProfile(any())).thenThrow(tDioException);

        // when
        final call = dataSource.getProfile;

        // then
        await expectLater(
          () => call(tUserId),
          throwsA(ServerFailure(tDioException)),
        );
      },
    );
  });
}
