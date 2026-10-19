import 'package:flutter/widgets.dart';

import 'package:flutter_auth_template/core/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
