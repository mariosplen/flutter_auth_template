import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../domain/usecases/get_is_signed_in_use_case.dart';
import 'app_state.dart';

/// App-wide hydrated state.
class AppCubit({required final GetIsSignedInUseCase _isSignedIn})
    extends HydratedCubit<AppState> {
  this : super(AppState(isSignedIn: _isSignedIn()));

  void setThemeMode(AppThemeMode themeMode) =>
      emit(state.copyWith(themeMode: themeMode));

  void selectTab(AppTab tab) => emit(state.copyWith(selectedTab: tab));

  /// Called after every change to the AuthCubit.
  void checkSession() => emit(state.copyWith(isSignedIn: _isSignedIn()));

  /// Called when the session has been cleared, such as when the user signs
  /// out or the session expires.
  void sessionCleared() => emit(state.copyWith(isSignedIn: false));

  // Hydration replaces the constructor's state, so keep its isSignedIn value.
  @override
  AppState fromJson(Map<String, dynamic> json) =>
      AppState.fromJson(json).copyWith(isSignedIn: state.isSignedIn);

  @override
  Map<String, dynamic> toJson(AppState state) => state.toJson();
}
