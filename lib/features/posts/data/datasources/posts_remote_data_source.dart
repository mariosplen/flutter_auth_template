import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:injectable/injectable.dart';

import '../models/post_response_model.dart';
import 'posts_api.dart';

@lazySingleton
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
