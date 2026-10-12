// The states are created at runtime on purpose: two const states are the very
// same instance, which would not prove that they are compared by value.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_auth_template/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tProfile = Profile(
    name: 'Test User',
    createdAt: DateTime.utc(2026, 1, 1, 10),
  );
  final tFailure = ServerFailure(Exception('connection refused'));

  test(
    '''
    GIVEN nothing was requested yet
    WHEN a ProfileState is created without any arguments
    THEN its profile is initial''',
    () {
      // when
      final state = ProfileState();

      // then
      expect(state.profile, AsyncInitial<Profile>());
    },
  );

  group('equality', () {
    test(
      '''
      GIVEN two ProfileStates that hold the same profile
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = ProfileState(profile: AsyncData(tProfile));
        final second = ProfileState(profile: AsyncData(tProfile));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN a ProfileState that holds a profile and one that holds a failure
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = ProfileState(profile: AsyncData(tProfile));
        final second = ProfileState(profile: AsyncError(tFailure));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  group('copyWith', () {
    test(
      '''
      GIVEN a ProfileState whose profile is loading
      WHEN it is copied with a loaded profile
      THEN the copy holds the loaded profile''',
      () {
        // given
        final state = ProfileState(profile: AsyncLoading());

        // when
        final copy = state.copyWith(profile: AsyncData(tProfile));

        // then
        expect(copy, ProfileState(profile: AsyncData(tProfile)));
      },
    );
  });
}
