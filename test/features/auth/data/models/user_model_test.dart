import 'dart:convert';

import 'package:flutter_auth_template/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  const tEmail = 'test@example.com';

  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a user as Supabase Auth returns it
      WHEN a UserModel is created from it
      THEN the model has the id and the email of the JSON
      AND every other field of the JSON is ignored''',
      () {
        // given
        final json = jsonDecode(fixture('user.json')) as Map<String, dynamic>;

        // when
        final model = UserModel.fromJson(json);

        // then
        expect(model.id, tId);
        expect(model.email, tEmail);
      },
    );
  });

  group('toJson', () {
    test(
      '''
      GIVEN a UserModel
      WHEN it is converted to JSON
      THEN the JSON map contains its id and its email''',
      () {
        // given
        final model = UserModel(id: tId, email: tEmail);

        // when
        final json = model.toJson();

        // then
        expect(json, {'id': tId, 'email': tEmail});
      },
    );
  });
}
