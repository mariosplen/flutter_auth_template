import 'package:flutter_auth_template/features/posts/data/mappers/post_mapper.dart';
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tId = '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c';
  const tTitle = 'Test title';
  const tContent = 'Test content';
  final tCreatedAt = DateTime.utc(2026, 1, 2, 12, 30);

  group('toEntity', () {
    test(
      '''
      GIVEN a PostResponseModel that came from the data layer
      WHEN it is mapped to an entity
      THEN the result is a Post of the domain layer
      AND the Post has the id, title, content and creation date of the model''',
      () {
        // given
        final model = PostResponseModel(
          id: tId,
          title: tTitle,
          content: tContent,
          createdAt: tCreatedAt,
        );

        // when
        final entity = model.toEntity();

        // then
        expect(
          entity,
          Post(
            id: tId,
            title: tTitle,
            content: tContent,
            createdAt: tCreatedAt,
          ),
        );
      },
    );
  });
}
