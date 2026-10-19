import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_auth_template/features/profile/data/mappers/profile_mapper.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_auth_template/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl(final ProfileRemoteDataSource _remoteDataSource)
    implements ProfileRepository {
  @override
  Future<Result<Profile>> getProfile() async {
    try {
      // Profiles has no email, so it comes from the auth user.
      final user = await _remoteDataSource.getUser();
      final profile = await _remoteDataSource.getProfile(user.id);
      return Result.ok(profile.toEntity(email: user.email));
    } on Failure catch (failure) {
      return Result.error(failure);
    } on Object catch (error) {
      return Result.error(GenericFailure(error));
    }
  }
}
