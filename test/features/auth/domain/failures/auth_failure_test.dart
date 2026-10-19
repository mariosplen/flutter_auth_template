import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFailure', () {
    test(
      '''
      GIVEN an auth failure for wrong credentials created from an error
      WHEN its type and cause are read
      THEN the type is invalid credentials
      AND the cause is that error
      AND it is a Failure, so it is handled like every other failure''',
      () {
        // given
        final tError = StateError('invalid credentials');
        final tFailure = AuthFailure(
          AuthFailureType.invalidCredentials,
          tError,
        );
        // when
        final type = tFailure.type;
        final cause = tFailure.cause;
        // then
        expect(type, AuthFailureType.invalidCredentials);
        expect(cause, same(tError));
        expect(tFailure, isA<Failure>());
      },
    );

    test(
      '''
      GIVEN two auth failures with the same type and the same cause
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final tError = StateError('weak password');
        final tFirst = AuthFailure(AuthFailureType.weakPassword, tError);
        final tSecond = AuthFailure(AuthFailureType.weakPassword, tError);
        // when
        final isEqual = tFirst == tSecond;
        // then
        expect(isEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two auth failures with the same cause but different types
      WHEN they are compared
      THEN they are not equal, because the type is part of the failure''',
      () {
        // given
        final tError = StateError('cause');
        final tFirst = AuthFailure(AuthFailureType.weakPassword, tError);
        final tSecond = AuthFailure(AuthFailureType.userAlreadyExists, tError);
        // when
        final isEqual = tFirst == tSecond;
        // then
        expect(isEqual, isFalse);
      },
    );
  });
}
