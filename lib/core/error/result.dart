import 'package:flutter_auth_template/core/error/failures.dart';

/// The outcome of a repository call: [Ok] with a value or [Error] with a
/// [Failure]. Repositories return it instead of throwing.
sealed class const Result<T>() {
  const factory ok(T value) = Ok._;

  const factory error(Failure failure) = Error._;
}

final class const Ok<T>._(final T value) extends Result<T>;

final class const Error<T>._(final Failure failure) extends Result<T>;
