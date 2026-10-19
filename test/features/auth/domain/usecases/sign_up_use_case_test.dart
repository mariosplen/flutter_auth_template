import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository;

void main() {
  late SignUpUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignUpUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  const tResult = Result<SignUpResult>.ok(ConfirmationRequired());

  test(
    '''
    GIVEN no account exists for this email address yet
    WHEN the sign up use case is called with an email, a password and a name
    THEN the Ok result from the repository is returned
    AND the repository was asked to sign up with the same email, password
        and name
    AND nothing else was asked of the repository''',
    () async {
      // given
      when(
        () => mockAuthRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => tResult);
      // when
      final result = await usecase(
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
      );
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
