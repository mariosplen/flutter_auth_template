import 'package:equatable/equatable.dart';

import 'failures.dart';

/// The state of one async operation in a cubit state, modelled on
/// Riverpod's `AsyncValue`: not started, loading, done or failed.
sealed class AsyncValue<T> extends Equatable {
  const AsyncValue();
  @override
  List<Object?> get props => [];
}

final class AsyncInitial<T> extends AsyncValue<T> {
  const AsyncInitial();
}

final class AsyncLoading<T> extends AsyncValue<T> {
  const AsyncLoading();
}

final class AsyncData<T> extends AsyncValue<T> {
  const AsyncData(this.value);
  final T value;
  @override
  List<Object?> get props => [value];
}

final class AsyncError<T> extends AsyncValue<T> {
  const AsyncError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
