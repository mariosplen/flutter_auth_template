import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_response_model.dart';

extension SessionResponseModelMapper on SessionResponseModel {
  Session toEntity() =>
      Session(accessToken: accessToken, refreshToken: refreshToken);
}
