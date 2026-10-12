import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/app/app_state.dart';
import 'package:flutter_auth_template/core/app/app_theme_mode_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toThemeMode', () {
    test(
      '''
      GIVEN the system app theme mode
      WHEN it is converted to a Flutter ThemeMode
      THEN it is ThemeMode.system''',
      () {
        // given
        const appThemeMode = AppThemeMode.system;

        // when
        final themeMode = appThemeMode.toThemeMode();

        // then
        expect(themeMode, ThemeMode.system);
      },
    );

    test(
      '''
      GIVEN the light app theme mode
      WHEN it is converted to a Flutter ThemeMode
      THEN it is ThemeMode.light''',
      () {
        // given
        const appThemeMode = AppThemeMode.light;

        // when
        final themeMode = appThemeMode.toThemeMode();

        // then
        expect(themeMode, ThemeMode.light);
      },
    );

    test(
      '''
      GIVEN the dark app theme mode
      WHEN it is converted to a Flutter ThemeMode
      THEN it is ThemeMode.dark''',
      () {
        // given
        const appThemeMode = AppThemeMode.dark;

        // when
        final themeMode = appThemeMode.toThemeMode();

        // then
        expect(themeMode, ThemeMode.dark);
      },
    );
  });
}
