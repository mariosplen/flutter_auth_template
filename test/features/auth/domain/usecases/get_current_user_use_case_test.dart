import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockAuthRepository);
  });

  const tUser = User(
    id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
    email: 'test@example.com',
  );

  test(
    '''
    GIVEN the repository has a current user, because somebody is signed in
    WHEN the use case is called
    THEN the current user is read from the repository exactly once
    AND that user is returned''',
    () {
      // given
      when(() => mockAuthRepository.currentUser).thenReturn(tUser);

      // when
      final result = useCase();

      // then
      expect(result, tUser);
      verify(() => mockAuthRepository.currentUser).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    '''
    GIVEN the repository has no current user, because nobody is signed in
    WHEN the use case is called
    THEN nothing is returned''',
    () {
      // given
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      // when
      final result = useCase();

      // then
      expect(result, isNull);
      verify(() => mockAuthRepository.currentUser).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
