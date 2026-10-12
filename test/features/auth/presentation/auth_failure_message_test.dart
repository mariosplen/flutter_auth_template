import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations_en.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_auth_template/features/auth/presentation/auth_failure_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tL10n = AppLocalizationsEn();
  final tCause = Exception('the request was rejected');

  group('authMessage', () {
    final tMessagesByAuthFailureType = {
      AuthFailureType.emailAddressInvalid: tL10n.errorEmailAddressInvalid,
      AuthFailureType.validationFailed: tL10n.errorValidationFailed,
      AuthFailureType.invalidCredentials: tL10n.errorInvalidCredentials,
      AuthFailureType.emailNotConfirmed: tL10n.errorEmailNotConfirmed,
      AuthFailureType.userAlreadyExists: tL10n.errorUserAlreadyExists,
      AuthFailureType.weakPassword: tL10n.errorWeakPassword,
      AuthFailureType.overRequestRateLimit: tL10n.errorOverRequestRateLimit,
      AuthFailureType.overEmailSendRateLimit: tL10n.errorOverEmailSendRateLimit,
    };

    test(
      '''
      GIVEN the messages that the tests below expect
      WHEN they are compared with the types of AuthFailure that exist
      THEN there is a message for every single type''',
      () {
        // when
        final testedTypes = tMessagesByAuthFailureType.keys;

        // then
        expect(testedTypes, unorderedEquals(AuthFailureType.values));
      },
    );

    for (final MapEntry(key: tType, value: tMessage)
        in tMessagesByAuthFailureType.entries) {
      test(
        '''
        GIVEN an AuthFailure of the type ${tType.name}
        WHEN its auth message is asked for
        THEN it is the localized text "$tMessage"''',
        () {
          // given
          final failure = AuthFailure(tType, tCause);

          // when
          final message = failure.authMessage(tL10n);

          // then
          expect(message, tMessage);
        },
      );
    }

    test(
      '''
      GIVEN a ServerFailure, which is not an AuthFailure
      WHEN its auth message is asked for
      THEN it falls back to the localized "something went wrong" text''',
      () {
        // given
        final failure = ServerFailure(tCause);

        // when
        final message = failure.authMessage(tL10n);

        // then
        expect(message, tL10n.errorUnexpected);
      },
    );

    test(
      '''
      GIVEN a GenericFailure, which is not an AuthFailure
      WHEN its auth message is asked for
      THEN it falls back to the localized "something went wrong" text''',
      () {
        // given
        final failure = GenericFailure(tCause);

        // when
        final message = failure.authMessage(tL10n);

        // then
        expect(message, tL10n.errorUnexpected);
      },
    );
  });
}
