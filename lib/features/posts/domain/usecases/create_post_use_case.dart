import 'package:flutter_auth_template/core/error/result.dart';
import 'package:injectable/injectable.dart';

import '../entities/post.dart';
import '../repositories/posts_repository.dart';

@lazySingleton
class CreatePostUseCase(final PostsRepository _repository) {
  Future<Result<Post>> call({required String title, required String content}) =>
      _repository.createPost(title: title, content: content);
}
