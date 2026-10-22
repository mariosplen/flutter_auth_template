import 'package:equatable/equatable.dart';

abstract class const Failure(final Object cause)
    extends Equatable
    implements Exception {
  @override
  List<Object?> get props => [cause];
}

/// The server could not be reached, such as when the device is offline or
/// the request timed out.
class const NetworkFailure(super.cause) extends Failure;

class const ServerFailure(super.cause) extends Failure;

class const GenericFailure(super.cause) extends Failure;
