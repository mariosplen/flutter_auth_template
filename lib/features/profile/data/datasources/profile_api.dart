import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/data/models/user_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory(Dio dio) = _ProfileApi;

  @GET('/auth/v1/user')
  Future<UserResponseModel> getUser();

  @GET('/rest/v1/profiles')
  @Headers({'Accept': 'application/vnd.pgrst.object+json'})
  Future<ProfileResponseModel> getProfile(@Query('id') String idFilter);
}
