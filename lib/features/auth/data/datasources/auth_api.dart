import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api.g.dart';

const requiresAuthKey = 'requiresAuth';

@RestApi()
abstract class AuthApi {
  factory(Dio dio) = _AuthApi;

  @POST('/auth/v1/signup')
  @Extra({requiresAuthKey: false})
  Future<SignUpResponseModel> signUp(
    @Field() String email,
    @Field() String password,
    @Field() Map<String, dynamic> data,
  );

  @POST('/auth/v1/token?grant_type=password')
  @Extra({requiresAuthKey: false})
  Future<SessionModel> signIn(@Field() String email, @Field() String password);

  @POST('/auth/v1/token?grant_type=refresh_token')
  @Extra({requiresAuthKey: false})
  Future<SessionModel> refreshSession(
    @Field('refresh_token') String refreshToken,
  );

  // The scope=global option logs out from all devices.
  @POST('/auth/v1/logout?scope=local')
  Future<void> signOut();
}
