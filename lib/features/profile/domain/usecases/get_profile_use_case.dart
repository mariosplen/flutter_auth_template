import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase(final ProfileRepository _repository) {
  Future<Profile> call(String userId) => _repository.getProfile(userId);
}
