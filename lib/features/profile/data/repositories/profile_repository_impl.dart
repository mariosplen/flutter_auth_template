import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';
import 'package:flutter_auth_template/core/network/to_network_failure.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_api.dart';
import '../mappers/profile_mapper.dart';

class ProfileRepositoryImpl(final ProfileApi _profileApi)
    implements ProfileRepository {
  @override
  Future<Profile> getProfile(String userId) async {
    try {
      final profile = await _profileApi.getProfile('eq.$userId');
      return profile.toEntity();
    } on DioException catch (error) {
      throw error.toNetworkFailure() ?? UnexpectedFailure(error);
    } catch (error) {
      throw UnexpectedFailure(error);
    }
  }
}
