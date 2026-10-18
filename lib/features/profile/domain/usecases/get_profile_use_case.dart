import 'package:flutter_auth_template/core/error/result.dart';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase(final ProfileRepository _repository) {
  Future<Result<Profile>> call() => _repository.getProfile();
}
