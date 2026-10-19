import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';

extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => l10n.errorUnexpected;
}
