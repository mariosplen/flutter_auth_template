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
    if (state.posts case AsyncLoading()) return;
    emit(state.copyWith(posts: const AsyncLoading()));
    final result = await _getPosts();
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(posts: AsyncData(value)));
      case Error(:final failure):
        emit(state.copyWith(posts: AsyncError(failure)));
    }
  }

  Future<void> create({required String title, required String content}) async {
    if (state.createPost case AsyncLoading()) return;

    if (state.posts case AsyncData(value: final current)) {
      emit(state.copyWith(createPost: const AsyncLoading()));
      final result = await _createPost(title: title, content: content);
      switch (result) {
        case Ok(value: final post):
          emit(
            state.copyWith(
              createPost: AsyncData(post),
              posts: AsyncData([post, ...current]),
            ),
          );
        case Error(:final failure):
          emit(state.copyWith(createPost: AsyncError(failure)));
      }
    }
  }
}
