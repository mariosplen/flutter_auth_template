import 'package:flutter/material.dart';

import '../app/cubit/app_state.dart';

extension AppThemeModeMapper on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
    .system => .system,
    .light => .light,
    .dark => .dark,
  };
}
