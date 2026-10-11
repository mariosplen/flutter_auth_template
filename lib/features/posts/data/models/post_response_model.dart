import 'package:json_annotation/json_annotation.dart';

part 'post_response_model.g.dart';

@JsonSerializable(createToJson: false, fieldRename: .snake)
class PostResponseModel({
  required final String id,
  required final String title,
  required final String content,
  required final DateTime createdAt,
}) {
  factory PostResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PostResponseModelFromJson(json);
}
