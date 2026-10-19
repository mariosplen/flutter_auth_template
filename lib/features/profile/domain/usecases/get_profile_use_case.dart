import 'package:flutter_auth_template/core/error/result.dart';

import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_auth_template/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase(final ProfileRepository _repository) {
  Future<Result<Profile>> call() => _repository.getProfile();
}
