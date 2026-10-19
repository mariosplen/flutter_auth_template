import 'dart:convert';

import 'package:flutter_auth_template/features/profile/data/models/user_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a Supabase Auth user, which also has the role, the
            metadata and the confirmation date
      WHEN it is parsed into a user response model
      THEN the model has the id and the email
      AND the other fields are ignored''',
      () {
        // given
        final jsonMap =
            json.decode(fixture('user.json')) as Map<String, dynamic>;
        // when
        final result = UserResponseModel.fromJson(jsonMap);
        // then
        expect(result.id, '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f');
        expect(result.email, 'test@example.com');
      },
    );
  });
}
