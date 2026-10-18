import '../../domain/entities/session.dart';
import '../models/session_model.dart';

extension SessionModelMapper on SessionModel {
  Session toEntity() =>
      Session(accessToken: accessToken, refreshToken: refreshToken);
}

extension SessionMapper on Session {
  SessionModel toModel() =>
      SessionModel(accessToken: accessToken, refreshToken: refreshToken);
}
