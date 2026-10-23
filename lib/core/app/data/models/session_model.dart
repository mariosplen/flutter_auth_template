import 'package:json_annotation/json_annotation.dart';

part 'session_model.g.dart';

/// The form the session is stored in.
@JsonSerializable(fieldRename: .snake)
class SessionModel({
  required final String accessToken,
  required final String refreshToken,
}) {
  factory fromJson(Map<String, dynamic> json) => _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);
}
