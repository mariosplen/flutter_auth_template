import 'package:flutter_auth_template/core/app/domain/usecases/get_is_signed_in_use_case.dart';
import 'package:flutter_auth_template/core/app/presentation/cubit/app_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// App-wide hydrated state.
class AppCubit({required final GetIsSignedInUseCase _isSignedIn})
    extends HydratedCubit<AppState> {
  this : super(AppState(isSignedIn: _isSignedIn()));

  void setThemeMode(AppThemeMode themeMode) =>
      emit(state.copyWith(themeMode: themeMode));

  void selectTab(AppTab tab) => emit(state.copyWith(selectedTab: tab));

  /// Called after every change to the AuthCubit.
  void checkSession() {
    if (_isSignedIn()) {
      emit(state.copyWith(isSignedIn: true));
    } else {
      sessionCleared();
    }
  }

  /// Called when the session has been cleared, such as when the user signs
  /// out or the session expires. The next sign in starts on the posts tab.
  void sessionCleared() =>
      emit(state.copyWith(isSignedIn: false, selectedTab: .posts));

  // Hydration replaces the constructor's state, so keep its isSignedIn value.
  @override
  AppState fromJson(Map<String, dynamic> json) =>
      AppState.fromJson(json).copyWith(isSignedIn: state.isSignedIn);

  @override
  Map<String, dynamic> toJson(AppState state) => state.toJson();
}
