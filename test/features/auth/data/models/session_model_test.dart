import 'dart:convert';

import 'package:flutter_auth_template/features/auth/data/models/session_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tAccessToken = 'test-access-token';
  const tRefreshToken = 'test-refresh-token';
  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  const tEmail = 'test@example.com';

  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a session as Supabase Auth returns it
      WHEN a SessionModel is created from it
      THEN the model reads the access token from the access_token key
      AND the model reads the refresh token from the refresh_token key
      AND the model contains the user of the session''',
      () {
        // given
        final json =
            jsonDecode(fixture('session.json')) as Map<String, dynamic>;

        // when
        final model = SessionModel.fromJson(json);

        // then
        expect(model.accessToken, tAccessToken);
        expect(model.refreshToken, tRefreshToken);
        expect(model.user.id, tUserId);
        expect(model.user.email, tEmail);
      },
    );
  });

  group('toJson', () {
    test(
      '''
      GIVEN a SessionModel
      WHEN it is converted to JSON and encoded
      THEN the tokens are written with their snake case keys
      AND the user is written as a nested JSON object''',
      () {
        // given
        final model = SessionModel(
          accessToken: tAccessToken,
          refreshToken: tRefreshToken,
          user: UserModel(id: tUserId, email: tEmail),
        );

        // when
        final json = jsonDecode(jsonEncode(model.toJson()));

        // then
        expect(json, {
          'access_token': tAccessToken,
          'refresh_token': tRefreshToken,
          'user': {'id': tUserId, 'email': tEmail},
        });
      },
    );

    test(
      '''
      GIVEN a SessionModel that was converted to JSON and encoded
      WHEN a SessionModel is created again from that encoded JSON
      THEN the new model has the same tokens and the same user''',
      () {
        // given
        final model = SessionModel(
          accessToken: tAccessToken,
          refreshToken: tRefreshToken,
          user: UserModel(id: tUserId, email: tEmail),
        );
        final encoded = jsonEncode(model.toJson());

        // when
        final restored = SessionModel.fromJson(
          jsonDecode(encoded) as Map<String, dynamic>,
        );

        // then
        expect(restored.accessToken, tAccessToken);
        expect(restored.refreshToken, tRefreshToken);
        expect(restored.user.id, tUserId);
        expect(restored.user.email, tEmail);
      },
    );
  });
}
