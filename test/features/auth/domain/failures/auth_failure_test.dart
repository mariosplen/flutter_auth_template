import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFailure', () {
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
