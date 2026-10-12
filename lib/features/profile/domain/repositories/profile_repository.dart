import 'package:flutter_auth_template/core/error/result.dart';

import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Result<Profile>> getProfile(String userId);
}
