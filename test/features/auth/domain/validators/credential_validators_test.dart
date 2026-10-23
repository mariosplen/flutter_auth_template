import 'package:flutter_auth_template/features/auth/domain/validators/credential_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidEmail', () {
    test(
      '''
      GIVEN an email address with a name, an @ and a domain with a dot
      WHEN it is validated
      THEN it is valid''',
      () {
        // given
        const tEmail = 'test@example.com';
        // when
        final result = isValidEmail(tEmail);
        // then
        expect(result, isTrue);
      },
    );

    test(
      '''
      GIVEN an email address without an @
      WHEN it is validated
      THEN it is not valid''',
      () {
        // given
        const tEmail = 'test.example.com';
        // when
        final result = isValidEmail(tEmail);
        // then
        expect(result, isFalse);
      },
    );

    test(
      '''
      GIVEN an email address whose domain has no dot
      WHEN it is validated
      THEN it is not valid''',
      () {
        // given
        const tEmail = 'test@example';
        // when
        final result = isValidEmail(tEmail);
        // then
        expect(result, isFalse);
      },
    );

    test(
      '''
      GIVEN an email address with a space in it
      WHEN it is validated
      THEN it is not valid''',
      () {
        // given
        const tEmail = 'test user@example.com';
        // when
        final result = isValidEmail(tEmail);
        // then
        expect(result, isFalse);
      },
    );

    test(
      '''
      GIVEN an empty email address
      WHEN it is validated
      THEN it is not valid''',
      () {
        // given
        const tEmail = '';
        // when
        final result = isValidEmail(tEmail);
        // then
        expect(result, isFalse);
      },
    );

    test(
      '''
      GIVEN an email address with two @ in a row
      WHEN it is validated
      THEN it is not valid''',
      () {
        // given
        const tEmail = 'test@@example.com';
        // when
        final result = isValidEmail(tEmail);
        // then
        expect(result, isFalse);
      },
    );
  });

  group('isLongEnoughPassword', () {
    test(
      '''
      GIVEN a password with exactly 6 characters, which is Supabase's
            default minimum
      WHEN it is checked
      THEN it is long enough''',
      () {
        // given
        const tPassword = '123456';
        // when
        final result = isLongEnoughPassword(tPassword);
        // then
        expect(result, isTrue);
      },
    );

    test(
      '''
      GIVEN a password with 5 characters
      WHEN it is checked
      THEN it is not long enough''',
      () {
        // given
        const tPassword = '12345';
        // when
        final result = isLongEnoughPassword(tPassword);
        // then
        expect(result, isFalse);
      },
    );
  });
}
