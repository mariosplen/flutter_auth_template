import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile();
}
