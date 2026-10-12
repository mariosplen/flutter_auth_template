import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tCause = Exception('invalid login credentials');
  final tOtherCause = Exception('email not confirmed');

  test(
    '''
    GIVEN a type of authentication problem and the error that revealed it
    WHEN an AuthFailure is created with them
    THEN it is a Failure
    AND it holds that type
    AND it keeps the error as its cause''',
    () {
      // when
      final failure = AuthFailure(.invalidCredentials, tCause);

      // then
      expect(failure, isA<Failure>());
      expect(failure.type, AuthFailureType.invalidCredentials);
      expect(failure.cause, same(tCause));
    },
  );

  group('equality', () {
    test(
      '''
      GIVEN two AuthFailures with the same type and the same cause
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = AuthFailure(.invalidCredentials, tCause);
        final second = AuthFailure(.invalidCredentials, tCause);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two AuthFailures with the same cause but different types
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AuthFailure(.invalidCredentials, tCause);
        final second = AuthFailure(.emailNotConfirmed, tCause);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two AuthFailures with the same type but different causes
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AuthFailure(.invalidCredentials, tCause);
        final second = AuthFailure(.invalidCredentials, tOtherCause);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });
}
