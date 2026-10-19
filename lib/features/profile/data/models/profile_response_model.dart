import 'package:json_annotation/json_annotation.dart';

part 'profile_response_model.g.dart';

@JsonSerializable(createToJson: false, fieldRename: .snake)
class ProfileResponseModel({
  required final String id,
  required final String name,
  required final DateTime createdAt,
}) {
  factory fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);
}
