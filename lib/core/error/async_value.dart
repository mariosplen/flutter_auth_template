import 'package:equatable/equatable.dart';

import 'failures.dart';

sealed class AsyncValue<T> extends Equatable {
  const AsyncValue();

  bool get isLoading => this is AsyncLoading<T>;

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
