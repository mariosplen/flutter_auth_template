import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/presentation/auth_failure_message.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_auth_template/features/auth/presentation/screen/sign_in_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/app_cubit.dart';
import '../cubit/app_state.dart';
import 'app_tabs.dart';

/// Shows the tabs or the sign-in screen, and keeps the app state in sync
/// with auth.
class const App({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSignedIn = context.select(
      (AppCubit cubit) => cubit.state.isSignedIn,
    );
    return MultiBlocListener(
      listeners: [
        // Check for session changes on every auth state change.
        BlocListener<AuthCubit, AuthState>(
          listener: (context, _) => context.read<AppCubit>().checkSession(),
        ),
        // Sign-in listener.
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => previous.signIn != current.signIn,
          listener: (context, state) {
            if (state.signIn case AsyncError(:final failure)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.authMessage(context.l10n))),
              );
            }
          },
        ),
        // Sign-up listener.
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => previous.signUp != current.signUp,
          listener: (context, state) {
            switch (state.signUp) {
              case AsyncData(value: ConfirmationRequired()):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.confirmEmail)),
                );
                Navigator.of(context).pop();
              case AsyncError(:final failure):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(failure.authMessage(context.l10n))),
                );
              case _:
                break;
            }
          },
        ),
        // Close any pushed screen, such as when the session expires.
        BlocListener<AppCubit, AppState>(
          listenWhen: (previous, current) =>
              previous.isSignedIn != current.isSignedIn,
          listener: (context, _) =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
      child: switch (isSignedIn) {
        true => const AppTabs(),
        false => const SignInScreen(),
      },
    );
  }
}
