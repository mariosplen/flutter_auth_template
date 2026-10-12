import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/app/app.dart';
import 'package:flutter_auth_template/core/app/app_cubit.dart';
import 'package:flutter_auth_template/core/app/app_theme_mode_extensions.dart';
import 'package:flutter_auth_template/core/di/injection.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/session_storage.dart';
import 'package:flutter_auth_template/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationSupportDirectory()).path,
    ),
  );

  configureDependencies();
  await getIt<SessionStorage>().load();

  runApp(const MainApp());
}

class const MainApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final authCubit = getIt<AuthCubit>();
            getIt<Dio>().interceptors.add(
              AuthInterceptor(
                dio: getIt(),
                authApi: getIt(),
                sessionStorage: getIt(),
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
    );
  }
}
