import 'dart:convert';

import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a post row from PostgREST, which also has the author id
      WHEN it is parsed into a post response model
      THEN the model has the id, the title and the content
      AND the creation date is parsed as the same moment in UTC
      AND the author id is ignored, because the app does not show it''',
      () {
        // given
        final jsonMap =
            json.decode(fixture('post.json')) as Map<String, dynamic>;
        // when
        final result = PostResponseModel.fromJson(jsonMap);
        // then
        expect(result.id, '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c');
        expect(result.title, 'Test title');
        expect(result.content, 'Test content');
        expect(result.createdAt, DateTime.utc(2026, 1, 2, 12, 30));
      },
    );
  });
}
