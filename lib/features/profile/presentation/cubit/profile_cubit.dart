import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:flutter_auth_template/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit({required final GetProfileUseCase _getProfile})
    extends Cubit<ProfileState> {
  this : super(const ProfileState());

  Future<void> load() async {
    if (state.profile case AsyncLoading()) return;
    emit(state.copyWith(profile: const AsyncLoading()));
    final result = await _getProfile();
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(profile: AsyncData(value)));
      case Error(:final failure):
        emit(state.copyWith(profile: AsyncError(failure)));
    }
  }
}
