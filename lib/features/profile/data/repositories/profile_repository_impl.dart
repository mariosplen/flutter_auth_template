import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../mappers/profile_mapper.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl(final ProfileRemoteDataSource _remoteDataSource)
    implements ProfileRepository {
  @override
  Future<Result<Profile>> getProfile(String userId) async {
    try {
      final profile = await _remoteDataSource.getProfile(userId);
      return Result.ok(profile.toEntity());
    } on Failure catch (failure) {
      return Result.error(failure);
    }
  }
}
