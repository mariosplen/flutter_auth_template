import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tName = 'Test User';
  final tCreatedAt = DateTime.utc(2026, 1, 1, 10);

  test(
    '''
    GIVEN a name and a creation date
    WHEN a Profile is created with them
    THEN the Profile holds that name and that creation date''',
    () {
      // when
      final profile = Profile(name: tName, createdAt: tCreatedAt);

      // then
      expect(profile.name, tName);
      expect(profile.createdAt, tCreatedAt);
    },
  );

  group('equality', () {
    test(
      '''
      GIVEN two Profiles with the same name and the same creation date
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = Profile(name: tName, createdAt: tCreatedAt);
        final second = Profile(name: tName, createdAt: tCreatedAt);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two Profiles that only differ in their name
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = Profile(name: tName, createdAt: tCreatedAt);
        final second = Profile(name: 'Another User', createdAt: tCreatedAt);

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two Profiles that only differ in their creation date
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = Profile(name: tName, createdAt: tCreatedAt);
        final second = Profile(name: tName, createdAt: DateTime.utc(2027));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });
}
