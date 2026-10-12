import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/profile/domain/entities/profile.dart';
import 'package:flutter_auth_template/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:flutter_auth_template/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_auth_template/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

void main() {
  late MockGetProfileUseCase mockGetProfile;

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
  });

  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';

  ProfileCubit buildCubit() =>
      ProfileCubit(getProfile: mockGetProfile, userId: tUserId);

  final tProfile = Profile(
    name: 'Test User',
    createdAt: DateTime.utc(2026, 1, 1, 10),
  );
  final tFailure = ServerFailure(Exception('connection refused'));

  void setUpMockGetProfile(Result<Profile> result) {
    when(() => mockGetProfile(any())).thenAnswer((_) async => result);
  }

  group('initial state', () {
    test(
      '''
      GIVEN nothing was requested yet
      WHEN the cubit is created for a user
      THEN its profile is initial
      AND the use case is not called before somebody asks for it''',
      () {
        // when
        final cubit = buildCubit();

        // then
        expect(cubit.state, const ProfileState());
        verifyZeroInteractions(mockGetProfile);
      },
    );
  });

  group('load', () {
    blocTest<ProfileCubit, ProfileState>(
      '''
      GIVEN a cubit that was created for a user
      AND the get profile use case answers with the profile
      WHEN load is called
      THEN it emits a state whose profile is loading
      AND then a state whose profile holds the profile
      AND the use case is called once with the id of that user''',
      // given
      setUp: () => setUpMockGetProfile(Result.ok(tProfile)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const ProfileState(profile: AsyncLoading()),
        ProfileState(profile: AsyncData(tProfile)),
      ],
      verify: (_) {
        verify(() => mockGetProfile(tUserId)).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      '''
      GIVEN a cubit that was created for a user
      AND the get profile use case answers with a failure
      WHEN load is called
      THEN it emits a state whose profile is loading
      AND then a state whose profile holds the failure''',
      // given
      setUp: () => setUpMockGetProfile(Result.error(tFailure)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const ProfileState(profile: AsyncLoading()),
        ProfileState(profile: AsyncError(tFailure)),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      '''
      GIVEN a cubit whose last load failed
      AND the get profile use case answers with the profile this time
      WHEN load is called again, as when "try again" is pressed
      THEN it emits a state whose profile is loading instead of failed
      AND then a state whose profile holds the profile''',
      // given
      setUp: () => setUpMockGetProfile(Result.ok(tProfile)),
      build: buildCubit,
      seed: () => ProfileState(profile: AsyncError(tFailure)),
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const ProfileState(profile: AsyncLoading()),
        ProfileState(profile: AsyncData(tProfile)),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      '''
      GIVEN a cubit whose profile is already loading
      WHEN load is called a second time
      THEN it emits nothing
      AND the get profile use case is never called''',
      // given
      build: buildCubit,
      seed: () => const ProfileState(profile: AsyncLoading()),
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => const <ProfileState>[],
      verify: (_) {
        verifyNever(() => mockGetProfile(any()));
      },
    );
  });
}
