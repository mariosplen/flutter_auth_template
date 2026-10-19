import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_auth_template/core/app/domain/repositories/session_repository.dart';
import 'package:flutter_auth_template/core/app/domain/usecases/get_is_signed_in_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepository extends Mock implements SessionRepository;

void main() {
  late GetIsSignedInUseCase usecase;
  late MockSessionRepository mockSessionRepository;

  setUp(() {
    mockSessionRepository = MockSessionRepository();
    usecase = GetIsSignedInUseCase(mockSessionRepository);
  });

  const tSession = Session(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );

  test(
    '''
    GIVEN the session repository holds a session
    WHEN the use case checks whether the user is signed in
    THEN the user is signed in
    AND only the session was read from the repository''',
    () {
      // given
      when(() => mockSessionRepository.session).thenReturn(tSession);
      // when
      final result = usecase();
      // then
      expect(result, isTrue);
      verify(() => mockSessionRepository.session).called(1);
      verifyNoMoreInteractions(mockSessionRepository);
    },
  );

  test(
    '''
    GIVEN the session repository holds no session
    WHEN the use case checks whether the user is signed in
    THEN the user is signed out''',
    () {
      // given
      when(() => mockSessionRepository.session).thenReturn(null);
      // when
      final result = usecase();
      // then
      expect(result, isFalse);
    },
  );
}
