import 'package:flutter/widgets.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';
import 'package:flutter_auth_template/core/l10n/failure_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tL10n = lookupAppLocalizations(const Locale('en'));

  group('message', () {
    test(
      '''
      GIVEN a network failure, like when the device is offline
      WHEN its message is looked up in English
      THEN the "check your internet connection" message is returned''',
      () {
        // given
        const tFailure = NetworkFailure('cause');
        // when
        final result = tFailure.message(tL10n);
        // then
        expect(
          result,
          "Can't reach the server. Check your internet connection and try "
          'again.',
        );
      },
    );

    test(
      '''
      GIVEN a server failure, like when the server answers with an error
      WHEN its message is looked up in English
      THEN the generic "Something went wrong" message is returned''',
      () {
        // given
        const tFailure = ServerFailure('cause');
        // when
        final result = tFailure.message(tL10n);
        // then
        expect(result, 'Something went wrong. Please try again.');
      },
    );
  });
}
