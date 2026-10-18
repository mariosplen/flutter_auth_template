import 'package:flutter_auth_template/core/error/result.dart';

import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPostsUseCase(final PostsRepository _repository) {
  Future<Result<List<Post>>> call() => _repository.getPosts();
}
