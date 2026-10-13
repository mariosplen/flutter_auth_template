import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/app/app_cubit.dart';
import 'package:flutter_auth_template/core/di/injection.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/session_storage.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_api.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_auth_template/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/create_post_use_case.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/get_posts_use_case.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_api.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_auth_template/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_auth_template/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:flutter_auth_template/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(getIt.reset);

  group('configureDependencies', () {
    test(
      '''
      GIVEN a service locator that has nothing registered yet
      WHEN configureDependencies is called
      THEN the Dio and the secure storage of the register module are registered
      AND every api, data source, repository and use case is registered
      AND every cubit is registered''',
      () {
        // given
        expect(getIt.isRegistered<AuthCubit>(), isFalse);

        // when
        configureDependencies();

        // then
        expect(getIt.isRegistered<Dio>(), isTrue);
        expect(getIt.isRegistered<FlutterSecureStorage>(), isTrue);

        expect(getIt.isRegistered<AppCubit>(), isTrue);

        expect(getIt.isRegistered<AuthApi>(), isTrue);
        expect(getIt.isRegistered<SessionStorage>(), isTrue);
        expect(getIt.isRegistered<AuthRemoteDataSource>(), isTrue);
        expect(getIt.isRegistered<AuthRepository>(), isTrue);
        expect(getIt.isRegistered<GetCurrentUserUseCase>(), isTrue);
        expect(getIt.isRegistered<SignInUseCase>(), isTrue);
        expect(getIt.isRegistered<SignUpUseCase>(), isTrue);
        expect(getIt.isRegistered<SignOutUseCase>(), isTrue);
        expect(getIt.isRegistered<AuthCubit>(), isTrue);

        expect(getIt.isRegistered<PostsApi>(), isTrue);
        expect(getIt.isRegistered<PostsRemoteDataSource>(), isTrue);
        expect(getIt.isRegistered<PostsRepository>(), isTrue);
        expect(getIt.isRegistered<GetPostsUseCase>(), isTrue);
        expect(getIt.isRegistered<CreatePostUseCase>(), isTrue);
        expect(getIt.isRegistered<PostsCubit>(), isTrue);

        expect(getIt.isRegistered<ProfileApi>(), isTrue);
        expect(getIt.isRegistered<ProfileRemoteDataSource>(), isTrue);
        expect(getIt.isRegistered<ProfileRepository>(), isTrue);
        expect(getIt.isRegistered<GetProfileUseCase>(), isTrue);
        expect(getIt.isRegistered<ProfileCubit>(), isTrue);
      },
    );
  });
}
