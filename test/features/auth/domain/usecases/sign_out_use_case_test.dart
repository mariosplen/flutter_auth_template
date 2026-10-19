import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository;

void main() {
  late SignOutUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignOutUseCase(mockAuthRepository);
  });

  test(
    '''
    GIVEN a signed in user
    WHEN the sign out use case is called
    THEN the repository was asked to sign out
    AND nothing else was asked of the repository''',
    () async {
      // given
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
      // when
      await usecase();
      // then
      verify(() => mockAuthRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
