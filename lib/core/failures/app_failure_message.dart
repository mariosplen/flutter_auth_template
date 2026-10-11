import '../l10n/app_localizations.dart';
import 'app_failure.dart';

extension AppFailureMessage on AppFailure {
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.errorNetwork,
    _ => l10n.errorUnexpected,
  };
}
