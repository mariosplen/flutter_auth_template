import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/app/app.dart';
import 'package:flutter_auth_template/core/app/cubit/app_cubit.dart';
import 'package:flutter_auth_template/core/extensions/app_theme_mode_extensions.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';
import 'package:flutter_auth_template/core/network/dio_factory.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/session_storage.dart';
import 'package:flutter_auth_template/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:flutter_auth_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_auth_template/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_api.dart';
import 'package:flutter_auth_template/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_auth_template/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_api.dart';
import 'package:flutter_auth_template/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_auth_template/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationSupportDirectory()).path,
    ),
  );

  final sessionStorage = SessionStorage(const FlutterSecureStorage());
  await sessionStorage.load();

  runApp(MainApp(sessionStorage: sessionStorage));
}

class const MainApp({super.key, required final SessionStorage sessionStorage})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => createDio()),
        RepositoryProvider(create: (context) => AuthApi(context.read())),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            authApi: context.read(),
            sessionStorage: sessionStorage,
          ),
        ),
        RepositoryProvider(create: (context) => ProfileApi(context.read())),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(context.read()),
        ),
        RepositoryProvider(create: (context) => PostsApi(context.read())),
        RepositoryProvider<PostsRepository>(
          create: (context) => PostsRepositoryImpl(context.read()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final authCubit = AuthCubit(
                getCurrentUser: GetCurrentUserUseCase(context.read()),
                signIn: SignInUseCase(context.read()),
                signUp: SignUpUseCase(context.read()),
                signOut: SignOutUseCase(context.read()),
              );
              context.read<Dio>().interceptors.add(
                AuthInterceptor(
                  dio: context.read(),
                  authApi: context.read(),
                  sessionStorage: sessionStorage,
                  onSessionExpired: authCubit.sessionExpired,
                ),
              );
              return authCubit;
            },
          ),
          BlocProvider(
            create: (context) => AppCubit(
              isSignedIn: context.read<AuthCubit>().state.user != null,
            ),
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            darkTheme: ThemeData(brightness: .dark),
            themeMode: context.select(
              (AppCubit cubit) => cubit.state.themeMode.toThemeMode(),
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const App(),
          ),
        ),
      ),
    );
  }
}
