import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/data/models/user_response_model.dart';
import 'package:flutter_auth_template/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource;

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(mockRemoteDataSource);
  });

  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  const tEmail = 'test@example.com';
  final tCreatedAt = DateTime.utc(2026, 1, 1, 10);
  final tUserResponseModel = UserResponseModel(id: tUserId, email: tEmail);
  final tProfileResponseModel = ProfileResponseModel(
    id: tUserId,
    name: 'Test User',
    createdAt: tCreatedAt,
  );
  final tProfile = Profile(
    id: tUserId,
    name: 'Test User',
    email: tEmail,
    createdAt: tCreatedAt,
  );
  const tFailure = ServerFailure('offline');

  void setUpMockRemoteDataSourceGetUserSuccess() {
    when(() => mockRemoteDataSource.getUser())
        .thenAnswer((_) async => tUserResponseModel);
  }

  group('getProfile', () {
    test(
      '''
      GIVEN a signed in user
      AND the user has a profile row
      WHEN the profile is fetched
      THEN the profile is fetched by the id of the signed in user
      AND an Ok result is returned with the profile as an entity
      AND the email of the profile comes from the user, because the profiles
          table has no email''',
      () async {
        // given
        setUpMockRemoteDataSourceGetUserSuccess();
        when(() => mockRemoteDataSource.getProfile(any()))
            .thenAnswer((_) async => tProfileResponseModel);
        // when
        final result = await repository.getProfile();
        // then
        verify(() => mockRemoteDataSource.getProfile(tUserId)).called(1);
        expect(
          result,
          isA<Ok<Profile>>().having((ok) => ok.value, 'value', tProfile),
        );
      },
    );

    test(
      '''
      GIVEN the device is offline
      WHEN the profile is fetched
      THEN the profile itself is never fetched, because fetching the user
           already failed
      AND an Error result with the server failure from fetching the user is
          returned''',
      () async {
        // given
        when(() => mockRemoteDataSource.getUser()).thenThrow(tFailure);
        // when
        final result = await repository.getProfile();
        // then
        verifyNever(() => mockRemoteDataSource.getProfile(any()));
        expect(
          result,
          isA<Error<Profile>>().having((e) => e.failure, 'failure', tFailure),
        );
      },
    );

    test(
      '''
      GIVEN a signed in user
      AND the user has no profile row
      WHEN the profile is fetched
      THEN an Error result with the server failure from fetching the profile
           is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceGetUserSuccess();
        when(() => mockRemoteDataSource.getProfile(any())).thenThrow(tFailure);
        // when
        final result = await repository.getProfile();
        // then
        expect(
          result,
          isA<Error<Profile>>().having((e) => e.failure, 'failure', tFailure),
        );
      },
    );

    test(
      '''
      GIVEN Supabase Auth's user response has a shape the app does not expect
      WHEN the profile is fetched
      THEN an Error result with a generic failure is returned
      AND the generic failure has the parsing error as its cause''',
      () async {
        // given
        const tError = FormatException('unexpected profile');
        when(() => mockRemoteDataSource.getUser()).thenThrow(tError);
        // when
        final result = await repository.getProfile();
        // then
        expect(
          result,
          isA<Error<Profile>>().having(
            (e) => e.failure,
            'failure',
            const GenericFailure(tError),
          ),
        );
      },
    );
  });
}
