import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/app/presentation/app_theme_mode_extensions.dart';
import 'package:flutter_auth_template/core/app/presentation/cubit/app_cubit.dart';
import 'package:flutter_auth_template/core/app/presentation/screen/app.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_auth_template/injection_container.dart' as di;
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

  await di.init();

  runApp(const MainApp());
}

class const MainApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AppCubit>()),
        BlocProvider.value(value: di.sl<AuthCubit>()),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          darkTheme: ThemeData(brightness: .dark),
          themeMode: context.select<AppCubit, ThemeMode>(
            (cubit) => cubit.state.themeMode.toThemeMode(),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const App(),
        ),
      ),
    );
  }
}
