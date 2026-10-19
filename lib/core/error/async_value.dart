import 'package:equatable/equatable.dart';

import 'package:flutter_auth_template/core/error/failures.dart';

/// The state of one async operation in a cubit state, modelled on
/// Riverpod's `AsyncValue`: not started, loading, done or failed.
sealed class const AsyncValue<T>() extends Equatable {
  @override
  List<Object?> get props => [];
}

final class const AsyncInitial<T>() extends AsyncValue<T>;

final class const AsyncLoading<T>() extends AsyncValue<T>;

final class const AsyncData<T>(final T value) extends AsyncValue<T> {
  @override
  List<Object?> get props => [value];
}

final class const AsyncError<T>(final Failure failure) extends AsyncValue<T> {
  @override
  List<Object?> get props => [failure];
}
