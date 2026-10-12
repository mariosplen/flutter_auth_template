import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_auth_template/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_auth_template/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetProfileUseCase useCase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    useCase = GetProfileUseCase(mockProfileRepository);
  });

  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  final tProfile = Profile(
    name: 'Test User',
    createdAt: DateTime.utc(2026, 1, 1, 10),
  );

  void setUpMockProfileRepositoryGetProfile(Result<Profile> result) {
    when(() => mockProfileRepository.getProfile(any()))
        .thenAnswer((_) async => result);
  }

  test(
    '''
    GIVEN the repository loads the profile and answers with an Ok
    WHEN the use case is called with the id of a user
    THEN the repository is asked for the profile exactly once with that user id
    AND the Ok of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result.ok(tProfile);
      setUpMockProfileRepositoryGetProfile(tResult);

      // when
      final result = await useCase(tUserId);

      // then
      expect(result, same(tResult));
      verify(() => mockProfileRepository.getProfile(tUserId)).called(1);
      verifyNoMoreInteractions(mockProfileRepository);
    },
  );

  test(
    '''
    GIVEN the repository cannot load the profile and answers with an Error
    WHEN the use case is called with the id of a user
    THEN the Error of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result<Profile>.error(
        ServerFailure(Exception('connection refused')),
      );
      setUpMockProfileRepositoryGetProfile(tResult);

      // when
      final result = await useCase(tUserId);

      // then
      expect(result, same(tResult));
      verify(() => mockProfileRepository.getProfile(tUserId)).called(1);
      verifyNoMoreInteractions(mockProfileRepository);
    },
  );
}
