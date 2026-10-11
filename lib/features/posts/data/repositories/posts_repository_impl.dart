import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';
import 'package:flutter_auth_template/core/network/to_network_failure.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_api.dart';
import '../mappers/post_mapper.dart';

class PostsRepositoryImpl(final PostsApi _postsApi) implements PostsRepository {
  @override
  Future<List<Post>> getPosts() async {
    try {
      final posts = await _postsApi.getPosts();
      return [for (final post in posts) post.toEntity()];
    } on DioException catch (error) {
      throw error.toNetworkFailure() ?? UnexpectedFailure(error);
    } catch (error) {
      throw UnexpectedFailure(error);
    }
  }

  @override
  Future<Post> createPost({
    required String title,
    required String content,
  }) async {
    try {
      final post = await _postsApi.createPost(title, content);
      return post.toEntity();
    } on DioException catch (error) {
      throw error.toNetworkFailure() ?? UnexpectedFailure(error);
    } catch (error) {
      throw UnexpectedFailure(error);
    }
  }
}
