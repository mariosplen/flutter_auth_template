import 'package:flutter_auth_template/core/async/async_status.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/create_post_use_case.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/get_posts_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'posts_state.dart';

class PostsCubit({
  required final GetPostsUseCase _getPosts,
  required final CreatePostUseCase _createPost,
}) extends Cubit<PostsState> {
  this : super(const PostsState());

  Future<void> load() async {
    if (state.posts is Loading) return;
    emit(state.copyWith(posts: Loading()));
    try {
      final posts = await _getPosts();
      emit(state.copyWith(posts: Success(posts)));
    } on AppFailure catch (error) {
      emit(state.copyWith(posts: Failure(error)));
    }
  }

  Future<void> create({required String title, required String content}) async {
    if (state.createPost is Loading) return;

    if (state.posts case Success(data: final current)) {
      emit(state.copyWith(createPost: const Loading()));
      try {
        final post = await _createPost(title: title, content: content);
        emit(
          state.copyWith(
            createPost: Success(post),
            posts: Success([post, ...current]),
          ),
        );
      } on AppFailure catch (error) {
        emit(state.copyWith(createPost: Failure(error)));
      }
    }
  }
}
