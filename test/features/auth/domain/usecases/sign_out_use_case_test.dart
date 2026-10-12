import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOutUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockAuthRepository);
  });

  test(
    '''
    GIVEN the repository signs the user out
    WHEN the use case is called
    THEN the repository is asked to sign out exactly once
    AND the use case completes''',
    () async {
      // given
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      // when
      await useCase();

      // then
      verify(() => mockAuthRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
