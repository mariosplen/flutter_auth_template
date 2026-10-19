import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInUseCase extends Mock implements SignInUseCase;

class MockSignUpUseCase extends Mock implements SignUpUseCase;

class MockSignOutUseCase extends Mock implements SignOutUseCase;

void main() {
  late MockSignInUseCase mockSignIn;
  late MockSignUpUseCase mockSignUp;
  late MockSignOutUseCase mockSignOut;

  setUp(() {
    mockSignIn = MockSignInUseCase();
    mockSignUp = MockSignUpUseCase();
    mockSignOut = MockSignOutUseCase();
  });

  AuthCubit buildCubit() =>
      AuthCubit(signIn: mockSignIn, signUp: mockSignUp, signOut: mockSignOut);

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  const tFailure = AuthFailure(.invalidCredentials, 'cause');

  test(
    '''
    GIVEN a new auth cubit
    WHEN its state is read
    THEN sign in, sign up and sign out have not started''',
    () {
      // given
      final cubit = buildCubit();
      // when
      final result = cubit.state;
      // then
      expect(result, const AuthState());
    },
  );

  group('signIn', () {
    void setUpMockSignIn(Result<void> result) {
      when(
        () => mockSignIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => result);
    }

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN an account with this email and password
      WHEN the user signs in with the email and the password
      THEN the sign in is loading
      AND then the sign in is done
      AND the use case was asked to sign in with the same email and password''',
      // given
      setUp: () => setUpMockSignIn(const Result.ok(null)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => [
        const AuthState(signIn: AsyncLoading()),
        const AuthState(signIn: AsyncData(null)),
      ],
      verify: (_) =>
          verify(() => mockSignIn(email: tEmail, password: tPassword))
              .called(1),
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN the password is wrong
      WHEN the user signs in
      THEN the sign in is loading
      AND then the sign in failed with the auth failure from the use case''',
      // given
      setUp: () => setUpMockSignIn(const Result.error(tFailure)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => [
        const AuthState(signIn: AsyncLoading()),
        const AuthState(signIn: AsyncError(tFailure)),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a sign in is already loading
      WHEN the user taps sign in again
      THEN nothing is emitted
      AND the use case is not called a second time''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signIn: AsyncLoading()),
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => <AuthState>[],
      verify: (_) => verifyZeroInteractions(mockSignIn),
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a sign up is loading
      WHEN the user signs in at the same time
      THEN nothing is emitted
      AND the sign in use case is not called''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signUp: AsyncLoading()),
      // when
      act: (cubit) => cubit.signIn(email: tEmail, password: tPassword),
      // then
      expect: () => <AuthState>[],
      verify: (_) => verifyZeroInteractions(mockSignIn),
    );
  });

  group('signUp', () {
    void setUpMockSignUp(Result<SignUpResult> result) {
      when(
        () => mockSignUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => result);
    }

    Future<void> signUp(AuthCubit cubit) =>
        cubit.signUp(email: tEmail, password: tPassword, name: tName);

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN email confirmation is turned off in Supabase
      WHEN the user signs up with an email, a password and a name
      THEN the sign up is loading
      AND then the sign up is done with signed up, so the user is signed in
      AND the use case was asked to sign up with the same email, password
          and name''',
      // given
      setUp: () => setUpMockSignUp(const Result.ok(SignedUp())),
      build: buildCubit,
      // when
      act: signUp,
      // then
      expect: () => [
        const AuthState(signUp: AsyncLoading()),
        const AuthState(signUp: AsyncData(SignedUp())),
      ],
      verify: (_) => verify(
        () => mockSignUp(email: tEmail, password: tPassword, name: tName),
      ).called(1),
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN email confirmation is turned on in Supabase
      WHEN the user signs up
      THEN the sign up is loading
      AND then the sign up is done with confirmation required''',
      // given
      setUp: () => setUpMockSignUp(const Result.ok(ConfirmationRequired())),
      build: buildCubit,
      // when
      act: signUp,
      // then
      expect: () => [
        const AuthState(signUp: AsyncLoading()),
        const AuthState(signUp: AsyncData(ConfirmationRequired())),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN there is already an account with this email address
      WHEN the user signs up
      THEN the sign up is loading
      AND then the sign up failed with the auth failure from the use case''',
      // given
      setUp: () => setUpMockSignUp(const Result.error(tFailure)),
      build: buildCubit,
      // when
      act: signUp,
      // then
      expect: () => [
        const AuthState(signUp: AsyncLoading()),
        const AuthState(signUp: AsyncError(tFailure)),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a sign up is already loading
      WHEN the user taps sign up again
      THEN nothing is emitted
      AND the use case is not called a second time''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signUp: AsyncLoading()),
      // when
      act: signUp,
      // then
      expect: () => <AuthState>[],
      verify: (_) => verifyZeroInteractions(mockSignUp),
    );
  });

  group('signOut', () {
    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a signed in user
      WHEN the user signs out
      THEN the sign out is loading
      AND then the state is reset, which also clears the old sign in result
      AND the sign out use case was called''',
      // given
      setUp: () => when(() => mockSignOut()).thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => const AuthState(signIn: AsyncData(null)),
      // when
      act: (cubit) => cubit.signOut(),
      // then
      expect: () => [
        const AuthState(signIn: AsyncData(null), signOut: AsyncLoading()),
        const AuthState(),
      ],
      verify: (_) => verify(() => mockSignOut()).called(1),
    );

    blocTest<AuthCubit, AuthState>(
      '''
      GIVEN a sign out is already loading
      WHEN the user taps sign out again
      THEN nothing is emitted
      AND the use case is not called a second time''',
      // given
      build: buildCubit,
      seed: () => const AuthState(signOut: AsyncLoading()),
      // when
      act: (cubit) => cubit.signOut(),
      // then
      expect: () => <AuthState>[],
      verify: (_) => verifyZeroInteractions(mockSignOut),
    );
  });
}
