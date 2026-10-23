import 'dart:convert';

import 'package:flutter_auth_template/features/auth/data/models/session_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a Supabase token response, which also has the user,
            the token type and the expiry
      WHEN it is parsed into a session response model
      THEN the model has the access token and the refresh token
      AND the other fields are ignored''',
      () {
        // given
        final jsonMap =
            json.decode(fixture('session.json')) as Map<String, dynamic>;
        // when
        final result = SessionResponseModel.fromJson(jsonMap);
        // then
        expect(result.accessToken, 'test-access-token');
        expect(result.refreshToken, 'test-refresh-token');
      },
    );
  });
}
