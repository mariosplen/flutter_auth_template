import 'package:flutter/widgets.dart';
import 'package:flutter_auth_template/core/error/failure_message.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tL10n = lookupAppLocalizations(const Locale('en'));

  group('message', () {
    test(
      '''
      GIVEN a server failure, like when the server could not be reached
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

    test(
      '''
      GIVEN a generic failure, like when a response could not be parsed
      WHEN its message is looked up in English
      THEN the generic "Something went wrong" message is returned''',
      () {
        // given
        const tFailure = GenericFailure('cause');
        // when
        final result = tFailure.message(tL10n);
        // then
        expect(result, tL10n.errorUnexpected);
      },
    );
  });
}
