import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_auth_template/core/async/async_status.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';

part 'posts_state.g.dart';

@CopyWith()
class PostsState extends Equatable {
  const PostsState({this.posts = const Idle(), this.createPost = const Idle()});

  final AsyncStatus<List<Post>, AppFailure> posts;
  final AsyncStatus<Post, AppFailure> createPost;

  @override
  List<Object?> get props => [posts, createPost];
}
