import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
