import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import 'app_state.dart';

@injectable
class AppCubit({@factoryParam required bool isSignedIn})
    extends HydratedCubit<AppState> {
  this : super(AppState(isSignedIn: isSignedIn));

  void setThemeMode(AppThemeMode themeMode) =>
      emit(state.copyWith(themeMode: themeMode));

  void selectTab(AppTab tab) => emit(state.copyWith(selectedTab: tab));

  void setSignedIn(bool isSignedIn) =>
      emit(state.copyWith(isSignedIn: isSignedIn, selectedTab: .posts));

  @override
  AppState fromJson(Map<String, dynamic> json) =>
      AppState.fromJson(json).copyWith(isSignedIn: state.isSignedIn);

  @override
  Map<String, dynamic> toJson(AppState state) => state.toJson();
}
