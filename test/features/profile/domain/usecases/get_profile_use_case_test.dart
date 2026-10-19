import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_auth_template/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_auth_template/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository;

void main() {
  late GetProfileUseCase usecase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    usecase = GetProfileUseCase(mockProfileRepository);
  });

  final tResult = Result.ok(
    Profile(
      id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: DateTime.utc(2026, 1, 1, 10),
    ),
  );

  test(
    '''
    GIVEN a signed in user with a profile
    WHEN the get profile use case is called
    THEN the Ok result with the profile from the repository is returned
    AND only the profile was asked of the repository''',
    () async {
      // given
      when(() => mockProfileRepository.getProfile())
          .thenAnswer((_) async => tResult);
      // when
      final result = await usecase();
      // then
      expect(result, same(tResult));
      verify(() => mockProfileRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockProfileRepository);
    },
  );
}
