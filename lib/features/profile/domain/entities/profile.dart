import 'package:equatable/equatable.dart';

class const Profile({
  required final String id,
  required final String name,
  required final String email,
  required final DateTime createdAt,
}) extends Equatable {
  @override
  List<Object> get props => [id, name, email, createdAt];
}
