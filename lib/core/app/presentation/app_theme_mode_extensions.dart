import 'package:flutter/material.dart';

import 'package:flutter_auth_template/core/app/presentation/cubit/app_state.dart';

/// Converts to Flutter's [ThemeMode]. The state keeps its own enum so the
/// cubit doesn't depend on Flutter.
extension AppThemeModeMapper on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
    .system => .system,
    .light => .light,
    .dark => .dark,
  };
}
