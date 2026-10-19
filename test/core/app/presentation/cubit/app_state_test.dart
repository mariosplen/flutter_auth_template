import 'package:flutter_auth_template/core/app/presentation/cubit/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of an app state saved with the dark theme mode
      WHEN it is parsed into an app state
      THEN the app state has the dark theme mode
      AND the user is signed out and the posts tab is selected, as defaults''',
      () {
        // given
        final jsonMap = <String, dynamic>{'themeMode': 'dark'};
        // when
        final result = AppState.fromJson(jsonMap);
        // then
        expect(result, const AppState(themeMode: .dark));
      },
    );

    test(
      '''
      GIVEN the JSON of an app state that also has a signed in flag
            and a selected tab
      WHEN it is parsed into an app state
      THEN only the theme mode is read
      AND the user is signed out and the posts tab is selected, as defaults''',
      () {
        // given
        final jsonMap = <String, dynamic>{
          'themeMode': 'light',
          'isSignedIn': true,
          'selectedTab': 'settings',
        };
        // when
        final result = AppState.fromJson(jsonMap);
        // then
        expect(result, const AppState(themeMode: .light));
      },
    );
  });

  group('toJson', () {
    test(
      '''
      GIVEN a signed in user on the profile tab with the dark theme mode
      WHEN the app state is converted to JSON, so it can be saved
      THEN the JSON map only has the theme mode''',
      () {
        // given
        const tAppState = AppState(
          themeMode: .dark,
          isSignedIn: true,
          selectedTab: .profile,
        );
        // when
        final result = tAppState.toJson();
        // then
        expect(result, {'themeMode': 'dark'});
      },
    );
  });
}
