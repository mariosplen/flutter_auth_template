import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignInUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tUser = User(id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f', email: tEmail);

  void setUpMockAuthRepositorySignIn(Result<User> result) {
    when(
      () => mockAuthRepository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  test(
    '''
    GIVEN the repository signs the user in and answers with an Ok
    WHEN the use case is called with an email and a password
    THEN the repository is asked to sign in exactly once
         with that email and that password
    AND the Ok of the repository is returned as it is''',
    () async {
      // given
      const tResult = Result.ok(tUser);
      setUpMockAuthRepositorySignIn(tResult);

      // when
      final result = await useCase(email: tEmail, password: tPassword);

      // then
      expect(result, same(tResult));
      verify(
        () => mockAuthRepository.signIn(email: tEmail, password: tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    '''
    GIVEN the repository cannot sign the user in and answers with an Error
    WHEN the use case is called with an email and a password
    THEN the Error of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result<User>.error(
        AuthFailure(.invalidCredentials, Exception('invalid credentials')),
      );
      setUpMockAuthRepositorySignIn(tResult);

      // when
      final result = await useCase(email: tEmail, password: tPassword);

      // then
      expect(result, same(tResult));
      verify(
        () => mockAuthRepository.signIn(email: tEmail, password: tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
