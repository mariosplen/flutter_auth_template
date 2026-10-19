import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_api.dart';
import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/data/models/user_response_model.dart';

class ProfileRemoteDataSource(final ProfileApi _profileApi) {
  Future<UserResponseModel> getUser() async {
    try {
      return await _profileApi.getUser();
    } on DioException catch (error) {
      throw ServerFailure(error);
    }
  }

  Future<ProfileResponseModel> getProfile(String userId) async {
    try {
      return await _profileApi.getProfile('eq.$userId');
    } on DioException catch (error) {
      throw ServerFailure(error);
    }
  }
}
