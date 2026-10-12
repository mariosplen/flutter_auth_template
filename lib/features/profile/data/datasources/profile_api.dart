import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/profile_response_model.dart';

part 'profile_api.g.dart';

@RestApi()
@lazySingleton
abstract class ProfileApi {
  @factoryMethod
  factory ProfileApi(Dio dio) = _ProfileApi;

  @GET('/rest/v1/profiles')
  @Headers({'Accept': 'application/vnd.pgrst.object+json'})
  Future<ProfileResponseModel> getProfile(@Query('id') String idFilter);
}
