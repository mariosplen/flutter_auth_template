import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_profile_use_case.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit({
  required final GetProfileUseCase _getProfile,
  @factoryParam required final String _userId,
}) extends Cubit<ProfileState> {
  this : super(const ProfileState());

  Future<void> load() async {
    if (state.profile.isLoading) return;
    emit(state.copyWith(profile: const AsyncLoading()));
    final result = await _getProfile(_userId);
    emit(switch (result) {
      Ok(:final value) => state.copyWith(profile: AsyncData(value)),
      Error(:final failure) => state.copyWith(profile: AsyncError(failure)),
    });
  }
}
