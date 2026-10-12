import 'package:flutter_auth_template/core/error/failure_message.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tL10n = AppLocalizationsEn();
  final tCause = Exception('connection refused');

  group('message', () {
    test(
      '''
      GIVEN a ServerFailure
      WHEN its message is asked for
      THEN it is the localized "something went wrong" text''',
      () {
        // given
        final failure = ServerFailure(tCause);

        // when
        final message = failure.message(tL10n);

        // then
        expect(message, tL10n.errorUnexpected);
      },
    );

    test(
      '''
      GIVEN a GenericFailure
      WHEN its message is asked for
      THEN it is the localized "something went wrong" text''',
      () {
        // given
        final failure = GenericFailure(tCause);

        // when
        final message = failure.message(tL10n);

        // then
        expect(message, tL10n.errorUnexpected);
      },
    );
  });
}
