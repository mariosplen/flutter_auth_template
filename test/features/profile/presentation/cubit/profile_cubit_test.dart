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

class MockGetProfileUseCase extends Mock implements GetProfileUseCase;

void main() {
  late MockGetProfileUseCase mockGetProfile;

  setUp(() {
    mockGetProfile = MockGetProfileUseCase();
  });

  ProfileCubit buildCubit() => ProfileCubit(getProfile: mockGetProfile);

  final tProfile = Profile(
    id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
    name: 'Test User',
    email: 'test@example.com',
    createdAt: DateTime.utc(2026, 1, 1, 10),
  );
  const tFailure = ServerFailure('offline');

  group('load', () {
    blocTest<ProfileCubit, ProfileState>(
      '''
      GIVEN a signed in user with a profile
      WHEN the profile is loaded
      THEN the profile is loading
      AND then the profile is loaded''',
      // given
      setUp: () =>
          when(() => mockGetProfile())
              .thenAnswer((_) async => Result.ok(tProfile)),
      build: buildCubit,
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
      GIVEN the device is offline
      WHEN the profile is loaded
      THEN the profile is loading
      AND then loading the profile failed with the server failure from the use
          case''',
      // given
      setUp: () =>
          when(() => mockGetProfile())
              .thenAnswer((_) async => const Result.error(tFailure)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const ProfileState(profile: AsyncLoading()),
        const ProfileState(profile: AsyncError(tFailure)),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      '''
      GIVEN a signed in user with a profile
      WHEN the profile is loaded
      AND the user signs out before the server answers, which closes the
          cubit
      THEN the profile is loading
      AND nothing else is emitted, because the cubit is closed''',
      // given
      setUp: () =>
          when(() => mockGetProfile())
              .thenAnswer((_) async => Result.ok(tProfile)),
      build: buildCubit,
      // when
      act: (cubit) async {
        final loading = cubit.load();
        await cubit.close();
        await loading;
      },
      // then
      expect: () => [const ProfileState(profile: AsyncLoading())],
    );
  });
}
