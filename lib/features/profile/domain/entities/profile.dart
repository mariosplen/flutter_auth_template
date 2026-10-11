import 'package:equatable/equatable.dart';

class const Profile({
  required final String name,
  required final DateTime createdAt,
}) extends Equatable {
  @override
  List<Object> get props => [name, createdAt];
}
