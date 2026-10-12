// The states are created at runtime on purpose: two const states are the very
// same instance, which would not prove that they are compared by value.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tUser = User(
    id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
    email: 'test@example.com',
  );
  final tFailure = ServerFailure(Exception('connection refused'));

  test(
    '''
    GIVEN nobody is signed in and nothing was requested yet
    WHEN an AuthState is created without any arguments
    THEN it has no user
    AND its sign in, sign up and sign out are all initial''',
    () {
      // when
      final state = AuthState();

      // then
      expect(state.user, isNull);
      expect(state.signIn, AsyncInitial<User>());
      expect(state.signUp, AsyncInitial<SignUpResult>());
      expect(state.signOut, AsyncInitial<void>());
    },
  );

  group('isLoading', () {
    test(
      '''
      GIVEN an AuthState whose sign in is loading
      WHEN isLoading is read
      THEN it is true''',
      () {
        // given
        final state = AuthState(signIn: AsyncLoading());

        // when
        final isLoading = state.isLoading;

        // then
        expect(isLoading, isTrue);
      },
    );

    test(
      '''
      GIVEN an AuthState whose sign up is loading
      WHEN isLoading is read
      THEN it is true''',
      () {
        // given
        final state = AuthState(signUp: AsyncLoading());

        // when
        final isLoading = state.isLoading;

        // then
        expect(isLoading, isTrue);
      },
    );

    test(
      '''
      GIVEN an AuthState where neither the sign in nor the sign up is loading
      WHEN isLoading is read
      THEN it is false''',
      () {
        // given
        final state = AuthState(
          user: tUser,
          signIn: AsyncData(tUser),
          signUp: AsyncError(tFailure),
        );

        // when
        final isLoading = state.isLoading;

        // then
        expect(isLoading, isFalse);
      },
    );

    test(
      '''
      GIVEN an AuthState whose sign out is the only thing that is loading
      WHEN isLoading is read
      THEN it is false, because it only speaks for the sign in and the sign up''',
      () {
        // given
        final state = AuthState(user: tUser, signOut: AsyncLoading());

        // when
        final isLoading = state.isLoading;

        // then
        expect(isLoading, isFalse);
      },
    );
  });

  group('equality', () {
    test(
      '''
      GIVEN two AuthStates with the same user and the same async values
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = AuthState(user: tUser, signIn: AsyncData(tUser));
        final second = AuthState(user: tUser, signIn: AsyncData(tUser));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two AuthStates that only differ in their user
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AuthState(user: tUser);
        final second = AuthState();

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two AuthStates that only differ in their sign in
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AuthState(signIn: AsyncLoading());
        final second = AuthState(signIn: AsyncError(tFailure));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two AuthStates that only differ in their sign up
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AuthState(signUp: AsyncLoading());
        final second = AuthState(signUp: AsyncError(tFailure));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two AuthStates that only differ in their sign out
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = AuthState(signOut: AsyncLoading());
        final second = AuthState();

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  group('copyWith', () {
    test(
      '''
      GIVEN a signed in AuthState
      WHEN it is copied with a loading sign out
      THEN the copy has the loading sign out
      AND the copy keeps the user and everything else''',
      () {
        // given
        final state = AuthState(user: tUser, signIn: AsyncData(tUser));

        // when
        final copy = state.copyWith(signOut: AsyncLoading());

        // then
        expect(
          copy,
          AuthState(
            user: tUser,
            signIn: AsyncData(tUser),
            signOut: AsyncLoading(),
          ),
        );
      },
    );
  });
}
