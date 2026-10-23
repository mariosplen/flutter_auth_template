import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_auth_template/core/app/domain/usecases/get_is_signed_in_use_case.dart';
import 'package:flutter_auth_template/core/app/presentation/cubit/app_cubit.dart';
import 'package:flutter_auth_template/core/app/presentation/cubit/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetIsSignedInUseCase extends Mock implements GetIsSignedInUseCase;

class MockStorage extends Mock implements Storage;

void main() {
  late MockGetIsSignedInUseCase mockGetIsSignedIn;
  late MockStorage mockStorage;

  setUp(() {
    mockGetIsSignedIn = MockGetIsSignedInUseCase();
    mockStorage = MockStorage();
    when(() => mockStorage.write(any(), any<dynamic>()))
        .thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;
  });

  AppCubit buildCubit() => AppCubit(isSignedIn: mockGetIsSignedIn);

  void setUpMockGetIsSignedIn({required bool isSignedIn}) {
    when(() => mockGetIsSignedIn()).thenReturn(isSignedIn);
  }

  group('initial state', () {
    test(
      '''
      GIVEN the user picked the dark theme on an earlier launch
      AND the saved app state still says the user is signed out
      AND the user is signed in now
      WHEN the app cubit is created
      THEN the dark theme is restored from the saved app state
      AND the user is signed in, because that always comes from the session''',
      () {
        // given
        setUpMockGetIsSignedIn(isSignedIn: true);
        when(() => mockStorage.read(any())).thenReturn(<String, dynamic>{
          'themeMode': 'dark',
          'isSignedIn': false,
        });
        // when
        final cubit = buildCubit();
        addTearDown(cubit.close);
        // then
        expect(cubit.state, const AppState(themeMode: .dark, isSignedIn: true));
      },
    );
  });

  group('setThemeMode', () {
    blocTest<AppCubit, AppState>(
      '''
      GIVEN a signed in user on the system theme mode
      WHEN the user picks the dark theme mode in the settings
      THEN the state has the dark theme mode
      AND only the theme mode is saved for the next launch''',
      // given
      setUp: () => setUpMockGetIsSignedIn(isSignedIn: true),
      build: buildCubit,
      // when
      act: (cubit) => cubit.setThemeMode(.dark),
      // then
      expect: () => [const AppState(themeMode: .dark, isSignedIn: true)],
      verify: (_) =>
          verify(() => mockStorage.write('AppCubit', {'themeMode': 'dark'})),
    );
  });

  group('selectTab', () {
    blocTest<AppCubit, AppState>(
      '''
      GIVEN a signed in user on the posts tab
      WHEN the user selects the profile tab
      THEN the state has the profile tab selected''',
      // given
      setUp: () => setUpMockGetIsSignedIn(isSignedIn: true),
      build: buildCubit,
      // when
      act: (cubit) => cubit.selectTab(.profile),
      // then
      expect: () => [const AppState(isSignedIn: true, selectedTab: .profile)],
    );
  });

  group('checkSession', () {
    blocTest<AppCubit, AppState>(
      '''
      GIVEN the app state says the user is signed out
      AND the user has signed in since then
      WHEN the session is checked, like after the auth state changed
      THEN the state says the user is signed in''',
      // given
      setUp: () => setUpMockGetIsSignedIn(isSignedIn: true),
      build: buildCubit,
      seed: () => const AppState(),
      // when
      act: (cubit) => cubit.checkSession(),
      // then
      expect: () => [const AppState(isSignedIn: true)],
    );

    blocTest<AppCubit, AppState>(
      '''
      GIVEN the app state says the user is signed in on the settings tab
      AND the user has signed out since then
      WHEN the session is checked, like after the auth state changed
      THEN the state says the user is signed out
      AND the posts tab is selected again, so the next sign in starts there''',
      // given
      setUp: () => setUpMockGetIsSignedIn(isSignedIn: false),
      build: buildCubit,
      seed: () => const AppState(isSignedIn: true, selectedTab: .settings),
      // when
      act: (cubit) => cubit.checkSession(),
      // then
      expect: () => [const AppState()],
    );
  });

  group('sessionCleared', () {
    blocTest<AppCubit, AppState>(
      '''
      GIVEN a signed in user on the profile tab with the dark theme mode
      WHEN the session is cleared, like when the refresh token expired
      THEN the state says the user is signed out
      AND the posts tab is selected again, so the next sign in starts there
      AND the theme mode stays the same''',
      // given
      setUp: () => setUpMockGetIsSignedIn(isSignedIn: true),
      build: buildCubit,
      seed: () => const AppState(
        themeMode: .dark,
        isSignedIn: true,
        selectedTab: .profile,
      ),
      // when
      act: (cubit) => cubit.sessionCleared(),
      // then
      expect: () => [const AppState(themeMode: .dark)],
    );
  });
}
