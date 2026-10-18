import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../models/profile_response_model.dart';
import '../models/user_response_model.dart';

part 'profile_api.g.dart';

@RestApi()
abstract class ProfileApi {
  factory ProfileApi(Dio dio) = _ProfileApi;

  @GET('/auth/v1/user')
  Future<UserResponseModel> getUser();

  @GET('/rest/v1/profiles')
  @Headers({'Accept': 'application/vnd.pgrst.object+json'})
  Future<ProfileResponseModel> getProfile(@Query('id') String idFilter);
}
