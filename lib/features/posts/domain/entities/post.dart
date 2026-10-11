import 'package:equatable/equatable.dart';

class const Post({
  required final String id,
  required final String title,
  required final String content,
  required final DateTime createdAt,
}) extends Equatable {
  @override
  List<Object> get props => [id, title, content, createdAt];
}
