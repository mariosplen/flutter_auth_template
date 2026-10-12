// The results are created at runtime on purpose: a const one would never run
// its constructor.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tUser = User(
    id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
    email: 'test@example.com',
  );

  String describe(SignUpResult result) => switch (result) {
    SignedUp(:final user) => 'signed up as ${user.email}',
    ConfirmationRequired() => 'confirmation required',
  };

  group('SignedUp', () {
    test(
      '''
      GIVEN the user of an account that was created and signed in right away
      WHEN a SignedUp is created with that user
      THEN it is a SignUpResult
      AND it holds that user''',
      () {
        // when
        final result = SignedUp(tUser);

        // then
        expect(result, isA<SignUpResult>());
        expect(result.user, tUser);
      },
    );
  });

  group('ConfirmationRequired', () {
    test(
      '''
      GIVEN an account that was created but still waits for its email
            to be confirmed
      WHEN a ConfirmationRequired is created
      THEN it is a SignUpResult''',
      () {
        // when
        final result = ConfirmationRequired();

        // then
        expect(result, isA<SignUpResult>());
      },
    );
  });

  test(
    '''
    GIVEN a SignedUp and a ConfirmationRequired
    WHEN each of them goes through a switch over SignUpResult
    THEN the SignedUp takes its own branch and exposes its user
    AND the ConfirmationRequired takes the other branch''',
    () {
      // given
      final SignUpResult signedUp = SignedUp(tUser);
      final SignUpResult confirmationRequired = ConfirmationRequired();

      // when
      final signedUpDescription = describe(signedUp);
      final confirmationRequiredDescription = describe(confirmationRequired);

      // then
      expect(signedUpDescription, 'signed up as test@example.com');
      expect(confirmationRequiredDescription, 'confirmation required');
    },
  );
}
