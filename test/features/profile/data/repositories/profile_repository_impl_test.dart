import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(mockRemoteDataSource);
  });

  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  final tProfileResponseModel = ProfileResponseModel(
    name: 'Test User',
    createdAt: DateTime.utc(2026, 1, 1, 10),
  );
  final tProfile = Profile(
    name: 'Test User',
    createdAt: DateTime.utc(2026, 1, 1, 10),
  );

  group('getProfile', () {
    test(
      '''
      GIVEN the remote data source returns a profile model
      WHEN getProfile is called with the id of a user
      THEN the remote data source is asked exactly once with that user id
      AND an Ok with the model mapped to a Profile entity is returned''',
      () async {
        // given
        when(() => mockRemoteDataSource.getProfile(any()))
            .thenAnswer((_) async => tProfileResponseModel);

        // when
        final result = await repository.getProfile(tUserId);

        // then
        expect(
          result,
          isA<Ok<Profile>>().having((ok) => ok.value, 'value', tProfile),
        );
        verify(() => mockRemoteDataSource.getProfile(tUserId)).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      '''
      GIVEN the remote data source throws a Failure
      WHEN getProfile is called
      THEN an Error with that very Failure is returned''',
      () async {
        // given
        final tServerFailure = ServerFailure(Exception('connection refused'));
        when(() => mockRemoteDataSource.getProfile(any()))
            .thenThrow(tServerFailure);

        // when
        final result = await repository.getProfile(tUserId);

        // then
        expect(
          result,
          isA<Error<Profile>>().having(
            (error) => error.failure,
            'failure',
            same(tServerFailure),
          ),
        );
      },
    );

    test(
      '''
      GIVEN the remote data source throws something that is not a Failure,
            like a response that could not be parsed
      WHEN getProfile is called
      THEN an Error with a GenericFailure is returned
      AND the GenericFailure carries what was thrown as its cause''',
      () async {
        // given
        final tUnexpectedError = StateError('the response could not be parsed');
        when(() => mockRemoteDataSource.getProfile(any()))
            .thenThrow(tUnexpectedError);

        // when
        final result = await repository.getProfile(tUserId);

        // then
        expect(
          result,
          isA<Error<Profile>>().having(
            (error) => error.failure,
            'failure',
            GenericFailure(tUnexpectedError),
          ),
        );
      },
    );
  });
}
