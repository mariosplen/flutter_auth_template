import 'dart:convert';

import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tAccessToken = 'test-access-token';
  const tRefreshToken = 'test-refresh-token';

  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a Supabase token response, which also has the user,
            the token type and the expiry
      WHEN it is parsed into a session model
      THEN the session model has the access token and the refresh token
      AND the other fields are ignored''',
      () {
        // given
        final jsonMap =
            json.decode(fixture('session.json')) as Map<String, dynamic>;
        // when
        final result = SessionModel.fromJson(jsonMap);
        // then
        expect(result.accessToken, tAccessToken);
        expect(result.refreshToken, tRefreshToken);
      },
    );

    test(
      '''
      GIVEN the JSON of a session that was stored on an earlier launch
      WHEN it is parsed into a session model
      THEN the session model has the stored access token and refresh token''',
      () {
        // given
        final jsonMap =
            json.decode(fixture('session_cached.json')) as Map<String, dynamic>;
        // when
        final result = SessionModel.fromJson(jsonMap);
        // then
        expect(result.accessToken, tAccessToken);
        expect(result.refreshToken, tRefreshToken);
      },
    );
  });

  group('toJson', () {
    test(
      '''
      GIVEN a session model with an access token and a refresh token
      WHEN it is converted to JSON, so it can be stored
      THEN the JSON map has the tokens under snake_case keys
      AND nothing else''',
      () {
        // given
        final tSessionModel = SessionModel(
          accessToken: tAccessToken,
          refreshToken: tRefreshToken,
        );
        // when
        final result = tSessionModel.toJson();
        // then
        final expectedMap = {
          'access_token': tAccessToken,
          'refresh_token': tRefreshToken,
        };
        expect(result, expectedMap);
      },
    );
  });
}
