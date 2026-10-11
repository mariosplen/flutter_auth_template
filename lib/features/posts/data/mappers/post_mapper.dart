import '../../domain/entities/post.dart';
import '../models/post_response_model.dart';

extension PostResponseModelMapper on PostResponseModel {
  Post toEntity() =>
      Post(id: id, title: title, content: content, createdAt: createdAt);
}
