import 'package:flutter_auth_template/core/error/result.dart';
import 'package:injectable/injectable.dart';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class GetProfileUseCase(final ProfileRepository _repository) {
  Future<Result<Profile>> call(String userId) => _repository.getProfile(userId);
}
