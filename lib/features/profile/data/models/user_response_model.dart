import 'package:json_annotation/json_annotation.dart';

part 'user_response_model.g.dart';

@JsonSerializable(createToJson: false)
class UserResponseModel({
  required final String id,
  required final String email,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$UserResponseModelFromJson(json);
}
