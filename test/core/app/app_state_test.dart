// The states are created at runtime on purpose: two const states are the very
// same instance, which would not prove that they are compared by value.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_auth_template/core/app/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    '''
    GIVEN nothing was chosen yet
    WHEN an AppState is created without any arguments
    THEN it follows the system theme
    AND it is signed out
    AND it has the posts tab selected''',
    () {
      // when
      final state = AppState();

      // then
      expect(state.themeMode, AppThemeMode.system);
      expect(state.isSignedIn, isFalse);
      expect(state.selectedTab, AppTab.posts);
    },
  );

  group('equality', () {
    test(
      '''
      GIVEN two AppStates with the same theme, sign in status and tab
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = AppState(
          themeMode: .dark,
          isSignedIn: true,
          selectedTab: .profile,
        );
        final second = AppState(
          themeMode: .dark,
          isSignedIn: true,
          selectedTab: .profile,
        );

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two AppStates that only differ in their theme
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AppState(themeMode: .light);
        final second = AppState(themeMode: .dark);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two AppStates that only differ in their sign in status
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AppState(isSignedIn: true);
        final second = AppState(isSignedIn: false);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two AppStates that only differ in their selected tab
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AppState(selectedTab: .posts);
        final second = AppState(selectedTab: .settings);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  group('fromJson', () {
    test(
      '''
      GIVEN a JSON map that was stored with the dark theme
      WHEN an AppState is created from it
      THEN it has the dark theme''',
      () {
        // given
        final json = <String, dynamic>{'themeMode': 'dark'};

        // when
        final state = AppState.fromJson(json);

        // then
        expect(state.themeMode, AppThemeMode.dark);
      },
    );

    test(
      '''
      GIVEN an empty JSON map, as when nothing was stored before
      WHEN an AppState is created from it
      THEN it falls back to the system theme''',
      () {
        // given
        final json = <String, dynamic>{};

        // when
        final state = AppState.fromJson(json);

        // then
        expect(state.themeMode, AppThemeMode.system);
      },
    );

    test(
      '''
      GIVEN a JSON map that also claims to be signed in on the settings tab
      WHEN an AppState is created from it
      THEN only the theme is read from the JSON
      AND the sign in status and the tab keep their defaults''',
      () {
        // given
        final json = <String, dynamic>{
          'themeMode': 'light',
          'isSignedIn': true,
          'selectedTab': 'settings',
        };

        // when
        final state = AppState.fromJson(json);

        // then
        expect(state.themeMode, AppThemeMode.light);
        expect(state.isSignedIn, isFalse);
        expect(state.selectedTab, AppTab.posts);
      },
    );
  });

  group('toJson', () {
    test(
      '''
      GIVEN a signed in AppState with the light theme on the settings tab
      WHEN it is converted to JSON
      THEN the JSON map only contains the theme
      AND the sign in status and the tab are never stored''',
      () {
        // given
        final state = AppState(
          themeMode: .light,
          isSignedIn: true,
          selectedTab: .settings,
        );

        // when
        final json = state.toJson();

        // then
        expect(json, {'themeMode': 'light'});
      },
    );
  });
}
