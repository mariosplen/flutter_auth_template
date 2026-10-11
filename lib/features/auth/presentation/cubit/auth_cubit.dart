import 'package:flutter_auth_template/core/async/async_status.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sign_up_result.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import 'auth_state.dart';

class AuthCubit({
  required GetCurrentUserUseCase getCurrentUser,
  required final SignInUseCase _signIn,
  required final SignUpUseCase _signUp,
  required final SignOutUseCase _signOut,
}) extends Cubit<AuthState> {
  this : super(AuthState(user: getCurrentUser()));

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading) return;
    emit(state.copyWith(signIn: const Loading()));
    try {
      final user = await _signIn(email: email, password: password);
      emit(state.copyWith(user: user, signIn: Success(user)));
    } on AppFailure catch (error) {
      emit(state.copyWith(signIn: Failure(error)));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(signUp: const Loading()));
    try {
      final result = await _signUp(
        email: email,
        password: password,
        name: name,
      );
      emit(switch (result) {
        SignedUp(:final user) => state.copyWith(
          user: user,
          signUp: Success(result),
        ),
        ConfirmationRequired() => state.copyWith(signUp: Success(result)),
      });
    } on AppFailure catch (error) {
      emit(state.copyWith(signUp: Failure(error)));
    }
  }

  Future<void> signOut() async {
    try {
      await _signOut();
    } on AppFailure {
      // sign out locally regardless
    }
    emit(const AuthState());
  }

  void sessionExpired() => emit(const AuthState());
}
