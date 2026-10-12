import '../l10n/app_localizations.dart';
import 'failures.dart';

extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => l10n.errorUnexpected;
}
