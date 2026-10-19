import 'dart:convert';

import 'package:flutter_auth_template/features/profile/data/models/profile_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a profile row from PostgREST
      WHEN it is parsed into a profile response model
      THEN the model has the id and the name
      AND the creation date is parsed as the same moment in UTC''',
      () {
        // given
        final jsonMap =
            json.decode(fixture('profile.json')) as Map<String, dynamic>;
        // when
        final result = ProfileResponseModel.fromJson(jsonMap);
        // then
        expect(result.id, '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f');
        expect(result.name, 'Test User');
        expect(result.createdAt, DateTime.utc(2026, 1, 1, 10));
      },
    );
  });
}
