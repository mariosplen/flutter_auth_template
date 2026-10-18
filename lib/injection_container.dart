import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/app/data/datasources/session_local_data_source.dart';
import 'core/app/data/repositories/session_repository_impl.dart';
import 'core/app/domain/repositories/session_repository.dart';
import 'core/app/domain/usecases/get_is_signed_in_use_case.dart';
import 'core/app/presentation/cubit/app_cubit.dart';
import 'core/network/dio_factory.dart';
import 'features/auth/data/datasources/auth_api.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/interceptors/auth_interceptor.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_use_case.dart';
import 'features/auth/domain/usecases/sign_out_use_case.dart';
import 'features/auth/domain/usecases/sign_up_use_case.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/posts/data/datasources/posts_api.dart';
import 'features/posts/data/datasources/posts_remote_data_source.dart';
import 'features/posts/data/repositories/posts_repository_impl.dart';
import 'features/posts/domain/repositories/posts_repository.dart';
import 'features/posts/domain/usecases/create_post_use_case.dart';
import 'features/posts/domain/usecases/get_posts_use_case.dart';
import 'features/posts/presentation/cubit/posts_cubit.dart';
import 'features/profile/data/datasources/profile_api.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_use_case.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Singleton cubits.
  sl.registerLazySingleton(() => AppCubit(isSignedIn: sl()));
  sl.registerLazySingleton(
    () => AuthCubit(signIn: sl(), signUp: sl(), signOut: sl()),
  );

  // Factory cubits (can be recreated).
  sl.registerFactory(() => PostsCubit(getPosts: sl(), createPost: sl()));
  sl.registerFactory(() => ProfileCubit(getProfile: sl()));

  // Use cases.
  sl.registerLazySingleton(() => GetIsSignedInUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));

  // Repositories.
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sessionRepository: sl()),
  );
  sl.registerLazySingleton<PostsRepository>(() => PostsRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Data sources.
  sl.registerLazySingleton(() => SessionLocalDataSource(sl()));
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton(() => PostsRemoteDataSource(sl()));
  sl.registerLazySingleton(() => ProfileRemoteDataSource(sl()));

  // APIs.
  sl.registerLazySingleton(() => AuthApi(sl()));
  sl.registerLazySingleton(() => PostsApi(sl()));
  sl.registerLazySingleton(() => ProfileApi(sl()));

  // External dependencies.
  sl.registerLazySingleton(() => createDio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Load the session into memory before any repository that needs it is created.
  await sl<SessionRepository>().load();

  // Add this last because it needs Dio and AuthApi.
  sl<Dio>().interceptors.add(
    AuthInterceptor(
      dio: sl(),
      authApi: sl(),
      sessionRepository: sl(),
      onSessionExpired: () => sl<AppCubit>().sessionCleared(),
    ),
  );
}
