import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isLoading', () {
    test(
      '''
      GIVEN an auth state where nothing has started
      WHEN it is checked whether it is loading
      THEN it is not loading''',
      () {
        // given
        const tAuthState = AuthState();
        // when
        final result = tAuthState.isLoading;
        // then
        expect(result, isFalse);
      },
    );

    test(
      '''
      GIVEN an auth state where a sign in is loading
      WHEN it is checked whether it is loading
      THEN it is loading, so the sign in and sign up buttons are disabled''',
      () {
        // given
        const tAuthState = AuthState(signIn: AsyncLoading());
        // when
        final result = tAuthState.isLoading;
        // then
        expect(result, isTrue);
      },
    );

    test(
      '''
      GIVEN an auth state where a sign up is loading
      WHEN it is checked whether it is loading
      THEN it is loading''',
      () {
        // given
        const tAuthState = AuthState(signUp: AsyncLoading());
        // when
        final result = tAuthState.isLoading;
        // then
        expect(result, isTrue);
      },
    );

    test(
      '''
      GIVEN an auth state where only a sign out is loading
      WHEN it is checked whether it is loading
      THEN it is not loading, because a sign out has its own loading state''',
      () {
        // given
        const tAuthState = AuthState(signOut: AsyncLoading());
        // when
        final result = tAuthState.isLoading;
        // then
        expect(result, isFalse);
      },
    );
  });
}
