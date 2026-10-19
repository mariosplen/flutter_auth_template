import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository;

void main() {
  late SignInUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tResult = Result<void>.ok(null);

  test(
    '''
    GIVEN an account with this email and password
    WHEN the sign in use case is called with the email and the password
    THEN the Ok result from the repository is returned
    AND the repository was asked to sign in with the same email and password
    AND nothing else was asked of the repository''',
    () async {
      // given
      when(
        () => mockAuthRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tResult);
      // when
      final result = await usecase(email: tEmail, password: tPassword);
      // then
      expect(result, same(tResult));
      verify(
        () => mockAuthRepository.signIn(email: tEmail, password: tPassword),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
