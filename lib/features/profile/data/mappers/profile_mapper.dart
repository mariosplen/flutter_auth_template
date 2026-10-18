import '../../domain/entities/profile.dart';
import '../models/profile_response_model.dart';

extension ProfileResponseModelMapper on ProfileResponseModel {
  Profile toEntity({required String email}) =>
      Profile(id: id, name: name, email: email, createdAt: createdAt);
}
