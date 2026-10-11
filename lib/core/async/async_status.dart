import 'package:equatable/equatable.dart';

sealed class AsyncStatus<T, E> extends Equatable {
  const AsyncStatus();
  @override
  List<Object?> get props => [];
}

final class Idle extends AsyncStatus<Never, Never> {
  const Idle();
}

final class Loading extends AsyncStatus<Never, Never> {
  const Loading();
}

final class Success<T> extends AsyncStatus<T, Never> {
  const Success(this.data);
  final T data;
  @override
  List<Object?> get props => [data];
}

final class Failure<E> extends AsyncStatus<Never, E> {
  const Failure(this.error);
  final E error;

  @override
  bool operator ==(Object other) => identical(this, other);
  @override
  int get hashCode => identityHashCode(this);
}

extension AsyncStatusX<T, E> on AsyncStatus<T, E> {
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    _ => null,
  };
}
