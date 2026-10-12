import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockSignOutUseCase mockSignOut;

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockSignOut = MockSignOutUseCase();
    when(() => mockGetCurrentUser()).thenReturn(null);
  });

  AuthCubit buildCubit() => AuthCubit(
    getCurrentUser: mockGetCurrentUser,
    signIn: mockSignIn,
    signUp: mockSignUp,
    signOut: mockSignOut,
  );

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  const tUser = User(id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f', email: tEmail);
  const tSignedUp = SignedUp(tUser);
  const tConfirmationRequired = ConfirmationRequired();
  final tFailure = AuthFailure(
    .invalidCredentials,
    Exception('the request was rejected'),
  );

  void setUpMockSignIn(Result<User> result) {
    when(
      () => mockSignIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  void setUpMockSignUp(Result<SignUpResult> result) {
    when(
      () => mockSignUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => result);
  }

  void verifySignInWasNeverCalled() {
    verifyNever(
      () => mockSignIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  }

  void verifySignUpWasNeverCalled() {
    verifyNever(
      () => mockSignUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    );
  }

  group('initial state', () {
    test(
      '''
      GIVEN there is a current user, because a session was stored before
      WHEN the cubit is created
      THEN its state already holds that user
      AND nothing is loading''',
      () {
        // given
        when(() => mockGetCurrentUser()).thenReturn(tUser);

        // when
        final cubit = buildCubit();

        // then
        expect(cubit.state, const AuthState(user: tUser));
        verify(() => mockGetCurrentUser()).called(1);
      },
    );

    test(
      '''
      GIVEN there is no current user, because nobody is signed in
      WHEN the cubit is created
      THEN its state has no user
      AND nothing is loading''',
      () {
        // given
        when(() => mockGetCurrentUser()).thenReturn(null);

        // when
        final cubit = buildCubit();

        // then
        expect(cubit.state, const AuthState());
        verify(() => mockGetCurrentUser()).called(1);
      },
    );
  });

  group('signIn', () {
    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed out cubit
      AND the sign in use case answers with the user
      WHEN signIn is called with an email and a password
      THEN it emits a state whose sign in is loading
      AND then a state that holds the user and the data of the sign in
      AND the use case is called once with that email and that password''',
      // given
      setUp: () => setUpMockSignIn(const Result.ok(tUser)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => const [
        AuthState(signIn: AsyncLoading()),
        AuthState(user: tUser, signIn: AsyncData(tUser)),
      ],
      verify: (_) {
        verify(() => mockSignIn(email: tEmail, password: tPassword)).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed out cubit
      AND the sign in use case answers with a failure
      WHEN signIn is called with an email and a password
      THEN it emits a state whose sign in is loading
      AND then a state whose sign in holds the failure
      AND that state still has no user''',
      // given
      setUp: () => setUpMockSignIn(Result.error(tFailure)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => [
        const AuthState(signIn: AsyncLoading()),
        AuthState(signIn: AsyncError(tFailure)),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a cubit whose last sign in failed
      AND the sign in use case answers with the user this time
      WHEN signIn is called again
      THEN it emits a state whose sign in is loading instead of failed
      AND then a state that holds the user and the data of the sign in''',
      // given
      setUp: () => setUpMockSignIn(const Result.ok(tUser)),
      build: buildCubit,
      seed: () => AuthState(signIn: AsyncError(tFailure)),
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => const [
        AuthState(signIn: AsyncLoading()),
        AuthState(user: tUser, signIn: AsyncData(tUser)),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a cubit whose sign in is already loading
      WHEN signIn is called a second time
      THEN it emits nothing
      AND the sign in use case is never called''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signIn: AsyncLoading()),
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => const <AuthState>[],
      verify: (_) => verifySignInWasNeverCalled(),
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a cubit whose sign up is still loading
      WHEN signIn is called
      THEN it emits nothing
      AND the sign in use case is never called''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signUp: AsyncLoading()),
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => const <AuthState>[],
      verify: (_) => verifySignInWasNeverCalled(),
    );
  });

  group('signUp', () {
    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed out cubit
      AND the sign up use case answers that the user is signed up
      WHEN signUp is called with an email, a password and a name
      THEN it emits a state whose sign up is loading
      AND then a state that holds the user and the data of the sign up
      AND the use case is called once with that email, password and name''',
      // given
      setUp: () => setUpMockSignUp(const Result.ok(tSignedUp)),
      build: buildCubit,
      // when
      act: (cubit) =>
          cubit.signUp(email: tEmail, password: tPassword, name: tName),
      // then
      expect: () => const [
        AuthState(signUp: AsyncLoading()),
        AuthState(user: tUser, signUp: AsyncData(tSignedUp)),
      ],
      verify: (_) {
        verify(
          () => mockSignUp(email: tEmail, password: tPassword, name: tName),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed out cubit
      AND the sign up use case answers that the email has to be confirmed
      WHEN signUp is called with an email, a password and a name
      THEN it emits a state whose sign up is loading
      AND then a state whose sign up holds the required confirmation
      AND that state still has no user, because nobody is signed in yet''',
      // given
      setUp: () => setUpMockSignUp(const Result.ok(tConfirmationRequired)),
      build: buildCubit,
      // when
      act: (cubit) =>
          cubit.signUp(email: tEmail, password: tPassword, name: tName),
      // then
      expect: () => const [
        AuthState(signUp: AsyncLoading()),
        AuthState(signUp: AsyncData(tConfirmationRequired)),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed out cubit
      AND the sign up use case answers with a failure
      WHEN signUp is called with an email, a password and a name
      THEN it emits a state whose sign up is loading
      AND then a state whose sign up holds the failure
      AND that state still has no user''',
      // given
      setUp: () => setUpMockSignUp(Result.error(tFailure)),
      build: buildCubit,
      // when
      act: (cubit) =>
          cubit.signUp(email: tEmail, password: tPassword, name: tName),
      // then
      expect: () => [
        const AuthState(signUp: AsyncLoading()),
        AuthState(signUp: AsyncError(tFailure)),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a cubit whose sign up is already loading
      WHEN signUp is called a second time
      THEN it emits nothing
      AND the sign up use case is never called''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signUp: AsyncLoading()),
      // when
      act: (cubit) =>
          cubit.signUp(email: tEmail, password: tPassword, name: tName),
      // then
      expect: () => const <AuthState>[],
      verify: (_) => verifySignUpWasNeverCalled(),
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a cubit whose sign in is still loading
      WHEN signUp is called
      THEN it emits nothing
      AND the sign up use case is never called''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signIn: AsyncLoading()),
      // when
      act: (cubit) =>
          cubit.signUp(email: tEmail, password: tPassword, name: tName),
      // then
      expect: () => const <AuthState>[],
      verify: (_) => verifySignUpWasNeverCalled(),
    );
  });

  group('signOut', () {
    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed in cubit
      AND the sign out use case completes
      WHEN signOut is called
      THEN it emits a state that keeps the user while its sign out is loading
      AND then a brand new state with no user and nothing loading
      AND the use case is called once''',
      // given
      setUp: () => when(() => mockSignOut()).thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => const AuthState(user: tUser, signIn: AsyncData(tUser)),
      // when
      act: (cubit) => cubit.signOut(),
      // then
      expect: () => const [
        AuthState(
          user: tUser,
          signIn: AsyncData(tUser),
          signOut: AsyncLoading(),
        ),
        AuthState(),
      ],
      verify: (_) {
        verify(() => mockSignOut()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a cubit whose sign out is already loading
      WHEN signOut is called a second time
      THEN it emits nothing
      AND the sign out use case is never called''',
      // given
      build: buildCubit,
      seed: () => const AuthState(user: tUser, signOut: AsyncLoading()),
      // when
      act: (cubit) => cubit.signOut(),
      // then
      expect: () => const <AuthState>[],
      verify: (_) {
        verifyNever(() => mockSignOut());
      },
    );
  });

  group('sessionExpired', () {
    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed in cubit
      WHEN sessionExpired is called, because the session could not be refreshed
      THEN it emits a brand new state with no user and nothing loading
      AND the sign out use case is never called,
          because there is no session left to sign out of''',
      // given
      build: buildCubit,
      seed: () => const AuthState(user: tUser, signIn: AsyncData(tUser)),
      // when
      act: (cubit) => cubit.sessionExpired(),
      // then
      expect: () => const [AuthState()],
      verify: (_) {
        verifyNever(() => mockSignOut());
      },
    );
  });
}
