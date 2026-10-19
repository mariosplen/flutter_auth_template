import 'dart:convert';

import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a sign up response that has an access token,
            because email confirmation is turned off
      WHEN it is parsed into a sign up response model
      THEN it is a signed up response
      AND it has the session with the access token and the refresh token''',
      () {
        // given
        final jsonMap =
            json.decode(fixture('session.json')) as Map<String, dynamic>;
        // when
        final result = SignUpResponseModel.fromJson(jsonMap);
        // then
        expect(
          result,
          isA<SignedUpWithSession>()
              .having(
                (signedUp) => signedUp.session.accessToken,
                'session.accessToken',
                'test-access-token',
              )
              .having(
                (signedUp) => signedUp.session.refreshToken,
                'session.refreshToken',
                'test-refresh-token',
              ),
        );
      },
    );

    test(
      '''
      GIVEN the JSON of a sign up response that only has the user,
            because the email address has to be confirmed first
      WHEN it is parsed into a sign up response model
      THEN it is a needs confirmation response''',
      () {
        // given
        final jsonMap = json.decode(
          fixture('sign_up_needs_confirmation.json'),
        ) as Map<String, dynamic>;
        // when
        final result = SignUpResponseModel.fromJson(jsonMap);
        // then
        expect(result, isA<SignUpNeedsConfirmation>());
      },
    );
  });
}
