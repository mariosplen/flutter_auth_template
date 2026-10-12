import 'dart:convert';

import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a post as the Supabase REST API returns it
      WHEN a PostResponseModel is created from it
      THEN the model has the id, the title and the content of the JSON
      AND the model reads its creation date from the created_at key
      AND every other field of the JSON is ignored''',
      () {
        // given
        final json = jsonDecode(fixture('post.json')) as Map<String, dynamic>;

        // when
        final model = PostResponseModel.fromJson(json);

        // then
        expect(model.id, '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c');
        expect(model.title, 'Test title');
        expect(model.content, 'Test content');
        expect(model.createdAt, DateTime.utc(2026, 1, 2, 12, 30));
      },
    );
  });
}
