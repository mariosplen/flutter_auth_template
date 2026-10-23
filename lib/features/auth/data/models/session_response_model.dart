import 'package:json_annotation/json_annotation.dart';

part 'session_response_model.g.dart';

@JsonSerializable(createToJson: false, fieldRename: .snake)
class SessionResponseModel({
  required final String accessToken,
  required final String refreshToken,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$SessionResponseModelFromJson(json);
}
