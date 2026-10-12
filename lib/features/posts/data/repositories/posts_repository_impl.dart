import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';
import '../mappers/post_mapper.dart';

@LazySingleton(as: PostsRepository)
class PostsRepositoryImpl(final PostsRemoteDataSource _remoteDataSource)
    implements PostsRepository {
  @override
  Future<Result<List<Post>>> getPosts() async {
    try {
      final posts = await _remoteDataSource.getPosts();
      return Result.ok([for (final post in posts) post.toEntity()]);
    } on Failure catch (failure) {
      return Result.error(failure);
    }
  }

  @override
  Future<Result<Post>> createPost({
    required String title,
    required String content,
  }) async {
    try {
      final post = await _remoteDataSource.createPost(
        title: title,
        content: content,
      );
      return Result.ok(post.toEntity());
    } on Failure catch (failure) {
      return Result.error(failure);
    }
  }
}
