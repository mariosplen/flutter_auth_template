import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';

part 'posts_state.g.dart';

@CopyWith()
class const PostsState({
  final AsyncValue<List<Post>> posts = const AsyncInitial(),
  final AsyncValue<Post> createPost = const AsyncInitial(),
}) extends Equatable {
  @override
  List<Object?> get props => [posts, createPost];
}
