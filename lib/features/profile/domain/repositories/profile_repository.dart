import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile> getProfile(String userId);
}
