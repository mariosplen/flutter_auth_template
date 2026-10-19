import 'package:flutter_auth_template/features/posts/data/mappers/post_mapper.dart';
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toEntity', () {
    test(
      '''
      GIVEN a post response model from the server
      WHEN it is mapped to an entity
      THEN the post entity has the same id, title, content and creation date''',
      () {
        // given
        final tCreatedAt = DateTime.utc(2026, 1, 2, 12, 30);
        final tPostResponseModel = PostResponseModel(
          id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
          title: 'Test title',
          content: 'Test content',
          createdAt: tCreatedAt,
        );
        // when
        final result = tPostResponseModel.toEntity();
        // then
        expect(
          result,
          Post(
            id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
            title: 'Test title',
            content: 'Test content',
            createdAt: tCreatedAt,
          ),
        );
      },
    );
  });
}
