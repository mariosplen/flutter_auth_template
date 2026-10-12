import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_auth_template/core/app/app_cubit.dart';
import 'package:flutter_auth_template/core/app/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late MockStorage mockStorage;

  setUp(() {
    mockStorage = MockStorage();
    when(() => mockStorage.read(any())).thenReturn(null);
    when(() => mockStorage.write(any(), any<dynamic>()))
        .thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;
  });

  const tStorageKey = 'AppCubit';

  group('initial state', () {
    test(
      '''
      GIVEN nothing was stored before
      AND the user is signed out
      WHEN the cubit is created
      THEN its state follows the system theme
      AND its state is signed out
      AND its state has the posts tab selected''',
      () {
        // given
        when(() => mockStorage.read(tStorageKey)).thenReturn(null);

        // when
        final cubit = AppCubit(isSignedIn: false);

        // then
        expect(cubit.state, const AppState());
      },
    );

    test(
      '''
      GIVEN nothing was stored before
      AND the user is signed in
      WHEN the cubit is created
      THEN its state is signed in''',
      () {
        // given
        when(() => mockStorage.read(tStorageKey)).thenReturn(null);

        // when
        final cubit = AppCubit(isSignedIn: true);

        // then
        expect(cubit.state, const AppState(isSignedIn: true));
      },
    );

    test(
      '''
      GIVEN the dark theme was stored the last time the app ran
      AND the user is signed in
      WHEN the cubit is created
      THEN its state restores the dark theme from the storage
      AND its state is still signed in, because that is never stored''',
      () {
        // given
        when(() => mockStorage.read(tStorageKey))
            .thenReturn({'themeMode': 'dark'});

        // when
        final cubit = AppCubit(isSignedIn: true);

        // then
        expect(cubit.state, const AppState(themeMode: .dark, isSignedIn: true));
      },
    );
  });

  group('setThemeMode', () {
    blocTest<AppCubit, AppState>(
      '''
      GIVEN a cubit that follows the system theme
      WHEN setThemeMode is called with the dark theme
      THEN it emits a state with the dark theme
      AND it stores the dark theme, so that it survives a restart''',
      // given
      build: () => AppCubit(isSignedIn: true),
      // when
      act: (cubit) => cubit.setThemeMode(.dark),
      // then
      expect: () => const [AppState(themeMode: .dark, isSignedIn: true)],
      verify: (_) {
        verify(() => mockStorage.write(tStorageKey, {'themeMode': 'dark'}))
            .called(1);
      },
    );
  });

  group('selectTab', () {
    blocTest<AppCubit, AppState>(
      '''
      GIVEN a cubit that has the posts tab selected
      WHEN selectTab is called with the profile tab
      THEN it emits a state with the profile tab selected''',
      // given
      build: () => AppCubit(isSignedIn: true),
      // when
      act: (cubit) => cubit.selectTab(.profile),
      // then
      expect: () => const [AppState(isSignedIn: true, selectedTab: .profile)],
    );
  });

  group('setSignedIn', () {
    blocTest<AppCubit, AppState>(
      '''
      GIVEN a signed out cubit
      WHEN setSignedIn is called with true
      THEN it emits a signed in state''',
      // given
      build: () => AppCubit(isSignedIn: false),
      // when
      act: (cubit) => cubit.setSignedIn(true),
      // then
      expect: () => const [AppState(isSignedIn: true)],
    );

    blocTest<AppCubit, AppState>(
      '''
      GIVEN a signed in cubit that has the settings tab selected
      WHEN setSignedIn is called with false
      THEN it emits a signed out state
      AND that state is back on the posts tab, ready for the next sign in''',
      // given
      build: () => AppCubit(isSignedIn: true),
      seed: () => const AppState(isSignedIn: true, selectedTab: .settings),
      // when
      act: (cubit) => cubit.setSignedIn(false),
      // then
      expect: () => const [AppState()],
    );
  });
}
