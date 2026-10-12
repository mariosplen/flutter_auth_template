import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/create_post_use_case.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/get_posts_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'posts_state.dart';

@injectable
class PostsCubit({
  required final GetPostsUseCase _getPosts,
  required final CreatePostUseCase _createPost,
}) extends Cubit<PostsState> {
  this : super(const PostsState());

  Future<void> load() async {
    if (state.posts.isLoading) return;
    emit(state.copyWith(posts: const AsyncLoading()));
    final result = await _getPosts();
    emit(switch (result) {
      Ok(:final value) => state.copyWith(posts: AsyncData(value)),
      Error(:final failure) => state.copyWith(posts: AsyncError(failure)),
    });
  }

  Future<void> create({required String title, required String content}) async {
    if (state.createPost.isLoading) return;

    if (state.posts case AsyncData(value: final current)) {
      emit(state.copyWith(createPost: const AsyncLoading()));
      final result = await _createPost(title: title, content: content);
      emit(switch (result) {
        Ok(value: final post) => state.copyWith(
          createPost: AsyncData(post),
          posts: AsyncData([post, ...current]),
        ),
        Error(:final failure) => state.copyWith(
          createPost: AsyncError(failure),
        ),
      });
    }
  }
}
