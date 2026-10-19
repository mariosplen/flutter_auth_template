import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_state.g.dart';

enum AppTab { posts, profile, settings }

enum AppThemeMode { system, light, dark }

/// Only [themeMode] is saved between launches, as the one field with
/// `@JsonKey()`.
@CopyWith()
@JsonSerializable(ignoreUnannotated: true)
class const AppState({
  @JsonKey() final AppThemeMode themeMode = .system,
  final bool isSignedIn = false,
  final AppTab selectedTab = .posts,
}) extends Equatable {
  factory fromJson(Map<String, dynamic> json) => _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  @override
  List<Object> get props => [themeMode, isSignedIn, selectedTab];
}
