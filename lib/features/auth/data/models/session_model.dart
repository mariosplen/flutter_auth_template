import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'session_model.g.dart';

@JsonSerializable(fieldRename: .snake)
class SessionModel({
  required final String accessToken,
  required final String refreshToken,
  required final UserModel user,
}) {
  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);
}
