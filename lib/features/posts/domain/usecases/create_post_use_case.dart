import 'package:flutter_auth_template/core/error/result.dart';

import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/domain/repositories/posts_repository.dart';

class CreatePostUseCase(final PostsRepository _repository) {
  Future<Result<Post>> call({required String title, required String content}) =>
      _repository.createPost(title: title, content: content);
}
