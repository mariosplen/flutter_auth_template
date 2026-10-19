import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'posts_api.g.dart';

@RestApi()
abstract class PostsApi {
  factory(Dio dio) = _PostsApi;

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
