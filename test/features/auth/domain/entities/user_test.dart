// The users are created at runtime on purpose: two const users are the very
// same instance, which would not prove that they are compared by value.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_auth_template/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';
  const tEmail = 'test@example.com';

  test(
    '''
    GIVEN an id and an email
    WHEN a User is created with them
    THEN the User holds that id and that email''',
    () {
      // when
      final user = User(id: tId, email: tEmail);

      // then
      expect(user.id, tId);
      expect(user.email, tEmail);
    },
  );

  group('equality', () {
    test(
      '''
      GIVEN two Users with the same id and the same email
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = User(id: tId, email: tEmail);
        final second = User(id: tId, email: tEmail);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two Users with the same email but different ids
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = User(id: tId, email: tEmail);
        final second = User(id: 'another-id', email: tEmail);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two Users with the same id but different emails
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = User(id: tId, email: tEmail);
        final second = User(id: tId, email: 'another@example.com');

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });
}
