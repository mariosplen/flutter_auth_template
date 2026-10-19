import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  /// Retrieves the authenticated user's profile.
  Future<Result<Profile>> getProfile();
}
