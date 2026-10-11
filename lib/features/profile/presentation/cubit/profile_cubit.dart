import 'package:flutter_auth_template/core/async/async_status.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_use_case.dart';
import 'profile_state.dart';

class ProfileCubit({
  required final GetProfileUseCase _getProfile,
  required final String _userId,
}) extends Cubit<ProfileState> {
  this : super(const ProfileState());

  Future<void> load() async {
    if (state.profile is Loading) return;
    emit(state.copyWith(profile: const Loading()));
    try {
      final profile = await _getProfile(_userId);
      emit(state.copyWith(profile: Success(profile)));
    } on AppFailure catch (error) {
      emit(state.copyWith(profile: Failure(error)));
    }
  }
}
