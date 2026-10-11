import 'package:equatable/equatable.dart';

class const User({required final String id, required final String email})
    extends Equatable {
  @override
  List<Object> get props => [id, email];
}
