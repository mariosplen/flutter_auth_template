import 'dart:convert';

import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('fromJson', () {
    test(
      '''
      GIVEN the JSON of a sign up that Supabase answered with a session,
            as it does when the email does not have to be confirmed
      WHEN a SignUpResponseModel is created from it
      THEN the model is a SignedUpWithSession
      AND it contains the session of the JSON''',
      () {
        // given
        final json =
            jsonDecode(fixture('session.json')) as Map<String, dynamic>;

        // when
        final model = SignUpResponseModel.fromJson(json);

        // then
        expect(model, isA<SignedUpWithSession>());
        final session = (model as SignedUpWithSession).session;
        expect(session.accessToken, 'test-access-token');
        expect(session.refreshToken, 'test-refresh-token');
        expect(session.user.email, 'test@example.com');
      },
    );

    test(
      '''
      GIVEN the JSON of a sign up that Supabase answered with only the user,
            as it does when the email still has to be confirmed
      WHEN a SignUpResponseModel is created from it
      THEN the model is a SignUpNeedsConfirmation''',
      () {
        // given
        final json = jsonDecode(
          fixture('sign_up_needs_confirmation.json'),
        ) as Map<String, dynamic>;

        // when
        final model = SignUpResponseModel.fromJson(json);

        // then
        expect(model, isA<SignUpNeedsConfirmation>());
      },
    );

    test(
      '''
      GIVEN a JSON whose access_token is not a text
      WHEN a SignUpResponseModel is created from it
      THEN the model is a SignUpNeedsConfirmation,
           because there is no session that could be used''',
      () {
        // given
        final json = <String, dynamic>{'access_token': null};

        // when
        final model = SignUpResponseModel.fromJson(json);

        // then
        expect(model, isA<SignUpNeedsConfirmation>());
      },
    );
  });

  group('SignUpNeedsConfirmation', () {
    test(
      '''
      GIVEN a sign up that still waits for the email to be confirmed
      WHEN a SignUpNeedsConfirmation is created
      THEN it is one of the SignUpResponseModels''',
      () {
        // when
        // Created at runtime, a const one would never run the constructor.
        // ignore: prefer_const_constructors
        final model = SignUpNeedsConfirmation();

        // then
        expect(model, isA<SignUpResponseModel>());
      },
    );
  });
}
