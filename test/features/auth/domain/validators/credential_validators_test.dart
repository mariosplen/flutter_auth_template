import 'package:flutter_auth_template/features/auth/domain/validators/credential_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidEmail', () {
    for (final tEmail in [
      'test@example.com',
      'first.last@example.com',
      'test+alias@mail.example.co.uk',
    ]) {
      test(
        '''
        GIVEN "$tEmail", which has a name, an @ and a domain with a dot
        WHEN it is checked with isValidEmail
        THEN it is valid''',
        () {
          // when
          final isValid = isValidEmail(tEmail);

          // then
          expect(isValid, isTrue);
        },
      );
    }

    const tInvalidEmailsByReason = {
      'is empty': '',
      'has no @': 'test.example.com',
      'has nothing before the @': '@example.com',
      'has nothing after the @': 'test@',
      'has no dot in its domain': 'test@example',
      'has nothing after the dot of its domain': 'test@example.',
      'has two @': 'test@@example.com',
      'has a space in it': 'te st@example.com',
    };

    for (final MapEntry(key: tReason, value: tEmail)
        in tInvalidEmailsByReason.entries) {
      test(
        '''
        GIVEN "$tEmail", which $tReason
        WHEN it is checked with isValidEmail
        THEN it is not valid''',
        () {
          // when
          final isValid = isValidEmail(tEmail);

          // then
          expect(isValid, isFalse);
        },
      );
    }
  });

  group('isLongEnoughPassword', () {
    test(
      '''
      GIVEN a password that is one character shorter than the minimum length
      WHEN it is checked with isLongEnoughPassword
      THEN it is not long enough''',
      () {
        // given
        final tPassword = 'a' * (minPasswordLength - 1);

        // when
        final isLongEnough = isLongEnoughPassword(tPassword);

        // then
        expect(isLongEnough, isFalse);
      },
    );

    test(
      '''
      GIVEN a password that is exactly as long as the minimum length
      WHEN it is checked with isLongEnoughPassword
      THEN it is long enough''',
      () {
        // given
        final tPassword = 'a' * minPasswordLength;

        // when
        final isLongEnough = isLongEnoughPassword(tPassword);

        // then
        expect(isLongEnough, isTrue);
      },
    );

    test(
      '''
      GIVEN a password that is longer than the minimum length
      WHEN it is checked with isLongEnoughPassword
      THEN it is long enough''',
      () {
        // given
        final tPassword = 'a' * (minPasswordLength + 10);

        // when
        final isLongEnough = isLongEnoughPassword(tPassword);

        // then
        expect(isLongEnough, isTrue);
      },
    );

    test(
      '''
      GIVEN an empty password
      WHEN it is checked with isLongEnoughPassword
      THEN it is not long enough''',
      () {
        // given
        const tPassword = '';

        // when
        final isLongEnough = isLongEnoughPassword(tPassword);

        // then
        expect(isLongEnough, isFalse);
      },
    );
  });
}
