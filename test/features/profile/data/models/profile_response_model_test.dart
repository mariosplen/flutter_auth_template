import 'dart:convert';

import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a profile as the Supabase REST API returns it
      WHEN a ProfileResponseModel is created from it
      THEN the model has the name of the JSON
      AND the model reads its creation date from the created_at key
      AND every other field of the JSON is ignored''',
      () {
        // given
        final json =
            jsonDecode(fixture('profile.json')) as Map<String, dynamic>;

        // when
        final model = ProfileResponseModel.fromJson(json);

        // then
        expect(model.name, 'Test User');
        expect(model.createdAt, DateTime.utc(2026, 1, 1, 10));
      },
    );
  });
}
