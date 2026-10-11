import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/async/async_status.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';

import '../../domain/entities/sign_up_result.dart';
import '../../domain/entities/user.dart';

part 'auth_state.g.dart';

@CopyWith()
class const AuthState({
  final User? user,
  final AsyncStatus<User, AppFailure> signIn = const Idle(),
  final AsyncStatus<SignUpResult, AppFailure> signUp = const Idle(),
}) extends Equatable {
  bool get isLoading => signIn is Loading || signUp is Loading;

  @override
  List<Object?> get props => [user, signIn, signUp, isLoading];
}
