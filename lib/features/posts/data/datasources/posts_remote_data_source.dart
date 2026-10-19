import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_api.dart';
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';

class PostsRemoteDataSource(final PostsApi _postsApi) {
  Future<List<PostResponseModel>> getPosts() async {
    try {
      return await _postsApi.getPosts();
    } on DioException catch (error) {
      throw ServerFailure(error);
    }
  }

  Future<PostResponseModel> createPost({
    required String title,
    required String content,
  }) async {
    try {
      return await _postsApi.createPost(title, content);
    } on DioException catch (error) {
      throw ServerFailure(error);
    }
  }
}
