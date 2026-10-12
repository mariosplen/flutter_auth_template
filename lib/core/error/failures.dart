import 'package:equatable/equatable.dart';

abstract class const Failure(final Object cause)
    extends Equatable
    implements Exception {
  @override
  List<Object?> get props => [cause];
}

class const ServerFailure(super.cause) extends Failure;

class const GenericFailure(super.cause) extends Failure;
