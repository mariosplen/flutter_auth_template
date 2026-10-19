import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';

extension ProfileResponseModelMapper on ProfileResponseModel {
  Profile toEntity({required String email}) =>
      Profile(id: id, name: name, email: email, createdAt: createdAt);
}
