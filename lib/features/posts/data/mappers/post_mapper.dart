import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';

extension PostResponseModelMapper on PostResponseModel {
  Post toEntity() =>
      Post(id: id, title: title, content: content, createdAt: createdAt);
}
