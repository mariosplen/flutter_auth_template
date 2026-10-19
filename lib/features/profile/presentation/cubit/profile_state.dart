import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';

part 'profile_state.g.dart';

@CopyWith()
class const ProfileState({
  final AsyncValue<Profile> profile = const AsyncInitial(),
}) extends Equatable {
  @override
  List<Object?> get props => [profile];
}
