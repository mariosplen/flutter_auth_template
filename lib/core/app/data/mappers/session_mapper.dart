import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_auth_template/core/app/domain/entities/session.dart';

extension SessionModelMapper on SessionModel {
  Session toEntity() =>
      Session(accessToken: accessToken, refreshToken: refreshToken);
}

extension SessionMapper on Session {
  SessionModel toModel() =>
      SessionModel(accessToken: accessToken, refreshToken: refreshToken);
}
