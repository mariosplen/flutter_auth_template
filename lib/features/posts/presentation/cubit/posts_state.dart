import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';

part 'posts_state.g.dart';

@CopyWith()
class PostsState extends Equatable {
  const new({
    this.posts = const AsyncInitial(),
    this.createPost = const AsyncInitial(),
  });

  final AsyncValue<List<Post>> posts;
  final AsyncValue<Post> createPost;

  @override
  List<Object?> get props => [posts, createPost];
}
