import 'package:flutter/widgets.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_auth_template/features/auth/presentation/auth_failure_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tL10n = lookupAppLocalizations(const Locale('en'));

  group('authMessage', () {
    test(
      '''
      GIVEN an auth failure because the email address is not valid
      WHEN its message is looked up in English
      THEN the user is told that the email address is not valid''',
      () {
        // given
        const tFailure = AuthFailure(.emailAddressInvalid, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, tL10n.errorEmailAddressInvalid);
      },
    );

    test(
      '''
      GIVEN an auth failure because Supabase could not validate the input
      WHEN its message is looked up in English
      THEN the user is told that the validation failed''',
      () {
        // given
        const tFailure = AuthFailure(.validationFailed, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, tL10n.errorValidationFailed);
      },
    );

    test(
      '''
      GIVEN an auth failure because the email or the password is wrong
      WHEN its message is looked up in English
      THEN the user is told "Wrong email or password."''',
      () {
        // given
        const tFailure = AuthFailure(.invalidCredentials, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, 'Wrong email or password.');
      },
    );

    test(
      '''
      GIVEN an auth failure because the email address is not confirmed yet
      WHEN its message is looked up in English
      THEN the user is asked to confirm the email address first''',
      () {
        // given
        const tFailure = AuthFailure(.emailNotConfirmed, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, 'Please confirm your email first.');
      },
    );

    test(
      '''
      GIVEN an auth failure because there is already an account with this
            email address
      WHEN its message is looked up in English
      THEN the user is told that the account already exists''',
      () {
        // given
        const tFailure = AuthFailure(.userAlreadyExists, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, tL10n.errorUserAlreadyExists);
      },
    );

    test(
      '''
      GIVEN an auth failure because the password is too weak
      WHEN its message is looked up in English
      THEN the user is told "This password is too weak."''',
      () {
        // given
        const tFailure = AuthFailure(.weakPassword, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, 'This password is too weak.');
      },
    );

    test(
      '''
      GIVEN an auth failure because the user tried too many times
      WHEN its message is looked up in English
      THEN the user is told to wait because of the request rate limit''',
      () {
        // given
        const tFailure = AuthFailure(.overRequestRateLimit, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, tL10n.errorOverRequestRateLimit);
      },
    );

    test(
      '''
      GIVEN an auth failure because too many emails were sent
      WHEN its message is looked up in English
      THEN the user is told to wait because of the email rate limit''',
      () {
        // given
        const tFailure = AuthFailure(.overEmailSendRateLimit, 'cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, tL10n.errorOverEmailSendRateLimit);
      },
    );

    test(
      '''
      GIVEN a failure that is not an auth failure, like a server failure
      WHEN its auth message is looked up in English
      THEN the generic "Something went wrong" message is returned''',
      () {
        // given
        const tFailure = ServerFailure('cause');
        // when
        final result = tFailure.authMessage(tL10n);
        // then
        expect(result, 'Something went wrong. Please try again.');
      },
    );
  });
}
