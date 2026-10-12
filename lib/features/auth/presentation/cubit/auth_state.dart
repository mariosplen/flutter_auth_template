import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';

import '../../domain/entities/sign_up_result.dart';
import '../../domain/entities/user.dart';

part 'auth_state.g.dart';

@CopyWith()
class const AuthState({
  final User? user,
  final AsyncValue<User> signIn = const AsyncInitial(),
  final AsyncValue<SignUpResult> signUp = const AsyncInitial(),
}) extends Equatable {
  bool get isLoading => signIn.isLoading || signUp.isLoading;

  @override
  List<Object?> get props => [user, signIn, signUp, isLoading];
}
