import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/sign_up_result.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import 'auth_state.dart';

@injectable
class AuthCubit({
  required GetCurrentUserUseCase getCurrentUser,
  required final SignInUseCase _signIn,
  required final SignUpUseCase _signUp,
  required final SignOutUseCase _signOut,
}) extends Cubit<AuthState> {
  this : super(AuthState(user: getCurrentUser()));

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading) return;
    emit(state.copyWith(signIn: const AsyncLoading()));
    final result = await _signIn(email: email, password: password);
    emit(switch (result) {
      Ok(value: final user) => state.copyWith(
        user: user,
        signIn: AsyncData(user),
      ),
      Error(:final failure) => state.copyWith(signIn: AsyncError(failure)),
    });
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
        emit(switch (value) {
          SignedUp(:final user) => state.copyWith(
            user: user,
            signUp: AsyncData(value),
          ),
          ConfirmationRequired() => state.copyWith(signUp: AsyncData(value)),
        });
      case Error(:final failure):
        emit(state.copyWith(signUp: AsyncError(failure)));
    }
  }

  Future<void> signOut() async {
    await _signOut();
    emit(const AuthState());
  }

  void sessionExpired() => emit(const AuthState());
}
