import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignUpUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignUpUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  const tUser = User(id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f', email: tEmail);

  void setUpMockAuthRepositorySignUp(Result<SignUpResult> result) {
    when(
      () => mockAuthRepository.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => result);
  }

  test(
    '''
    GIVEN the repository creates the account and answers with an Ok
    WHEN the use case is called with an email, a password and a name
    THEN the repository is asked to sign up exactly once
         with that email, that password and that name
    AND the Ok of the repository is returned as it is''',
    () async {
      // given
      const tResult = Result<SignUpResult>.ok(SignedUp(tUser));
      setUpMockAuthRepositorySignUp(tResult);

      // when
      final result = await useCase(
        email: tEmail,
        password: tPassword,
        name: tName,
      );

      // then
      expect(result, same(tResult));
      verify(
        () => mockAuthRepository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    '''
    GIVEN the repository cannot create the account and answers with an Error
    WHEN the use case is called with an email, a password and a name
    THEN the Error of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result<SignUpResult>.error(
        AuthFailure(.userAlreadyExists, Exception('user already exists')),
      );
      setUpMockAuthRepositorySignUp(tResult);

      // when
      final result = await useCase(
        email: tEmail,
        password: tPassword,
        name: tName,
      );

      // then
      expect(result, same(tResult));
      verify(
        () => mockAuthRepository.signUp(
          email: tEmail,
          password: tPassword,
          name: tName,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
