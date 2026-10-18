import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';

import '../../domain/entities/sign_up_result.dart';

part 'auth_state.g.dart';

@CopyWith()
class const AuthState({
  final AsyncValue<void> signIn = const AsyncInitial(),
  final AsyncValue<SignUpResult> signUp = const AsyncInitial(),
  final AsyncValue<void> signOut = const AsyncInitial(),
}) extends Equatable {
  bool get isLoading => signIn is AsyncLoading || signUp is AsyncLoading;

  @override
  List<Object?> get props => [signIn, signUp, signOut, isLoading];
}
