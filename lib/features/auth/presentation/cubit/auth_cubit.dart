import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import 'auth_state.dart';

class AuthCubit({
  required final SignInUseCase _signIn,
  required final SignUpUseCase _signUp,
  required final SignOutUseCase _signOut,
}) extends Cubit<AuthState> {
  this : super(const AuthState());

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading) return;
    emit(state.copyWith(signIn: const AsyncLoading()));
    final result = await _signIn(email: email, password: password);
    switch (result) {
      case Ok():
        emit(state.copyWith(signIn: const AsyncData(null)));
      case Error(:final failure):
        emit(state.copyWith(signIn: AsyncError(failure)));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(signUp: const AsyncLoading()));
    final result = await _signUp(email: email, password: password, name: name);
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(signUp: AsyncData(value)));
      case Error(:final failure):
        emit(state.copyWith(signUp: AsyncError(failure)));
    }
  }

  Future<void> signOut() async {
    if (state.signOut case AsyncLoading()) return;
    emit(state.copyWith(signOut: const AsyncLoading()));
    await _signOut();
    // Also clear the old sign-in and sign-up results.
    emit(const AuthState());
  }
}
