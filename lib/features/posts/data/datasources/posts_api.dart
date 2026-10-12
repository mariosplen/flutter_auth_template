import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/post_response_model.dart';

part 'posts_api.g.dart';

@RestApi()
@lazySingleton
abstract class PostsApi {
  @factoryMethod
  factory PostsApi(Dio dio) = _PostsApi;

  @GET('/rest/v1/posts?select=*&order=created_at.desc')
  Future<List<PostResponseModel>> getPosts();

  @POST('/rest/v1/posts?select=*')
  @Headers({
    'Prefer': 'return=representation',
    'Accept': 'application/vnd.pgrst.object+json',
  })
  Future<PostResponseModel> createPost(
    @Field() String title,
    @Field() String content,
  );
}
