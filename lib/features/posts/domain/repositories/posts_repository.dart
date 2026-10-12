import 'package:flutter_auth_template/core/error/result.dart';

import '../entities/post.dart';

abstract interface class PostsRepository {
  Future<Result<List<Post>>> getPosts();

  Future<Result<Post>> createPost({
    required String title,
    required String content,
  });
}
