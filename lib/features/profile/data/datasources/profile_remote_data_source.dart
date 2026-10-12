import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:injectable/injectable.dart';

import '../models/profile_response_model.dart';
import 'profile_api.dart';

@lazySingleton
class ProfileRemoteDataSource(final ProfileApi _profileApi) {
  Future<ProfileResponseModel> getProfile(String userId) async {
    try {
      return await _profileApi.getProfile('eq.$userId');
    } on DioException catch (error) {
      throw ServerFailure(error);
    }
  }
}
