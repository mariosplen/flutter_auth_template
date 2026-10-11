import '../../domain/entities/profile.dart';
import '../models/profile_response_model.dart';

extension ProfileResponseModelMapper on ProfileResponseModel {
  Profile toEntity() => Profile(name: name, createdAt: createdAt);
}
