import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/async/async_status.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';

import '../../domain/entities/profile.dart';

part 'profile_state.g.dart';

@CopyWith()
class const ProfileState({
  final AsyncStatus<Profile, AppFailure> profile = const Idle(),
}) extends Equatable {
  @override
  List<Object?> get props => [profile];
}
