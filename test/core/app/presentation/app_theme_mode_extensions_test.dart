import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/app/presentation/app_theme_mode_extensions.dart';
import 'package:flutter_auth_template/core/app/presentation/cubit/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toThemeMode', () {
    test(
      '''
      GIVEN the user picked the system theme mode in the settings
      WHEN it is converted to a Flutter theme mode
      THEN it becomes ThemeMode.system, so the app follows the device''',
      () {
        // given
        const tAppThemeMode = AppThemeMode.system;
        // when
        final result = tAppThemeMode.toThemeMode();
        // then
        expect(result, ThemeMode.system);
      },
    );

    test(
      '''
      GIVEN the user picked the light theme mode in the settings
      WHEN it is converted to a Flutter theme mode
      THEN it becomes ThemeMode.light''',
      () {
        // given
        const tAppThemeMode = AppThemeMode.light;
        // when
        final result = tAppThemeMode.toThemeMode();
        // then
        expect(result, ThemeMode.light);
      },
    );

    test(
      '''
      GIVEN the user picked the dark theme mode in the settings
      WHEN it is converted to a Flutter theme mode
      THEN it becomes ThemeMode.dark''',
      () {
        // given
        const tAppThemeMode = AppThemeMode.dark;
        // when
        final result = tAppThemeMode.toThemeMode();
        // then
        expect(result, ThemeMode.dark);
      },
    );
  });
}
