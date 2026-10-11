import 'package:flutter/material.dart';
import 'package:flutter_auth_template/features/auth/presentation/screen/sign_in_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import 'app_tabs.dart';
import 'cubit/app_cubit.dart';

class const App({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSignedIn = context.select(
      (AppCubit cubit) => cubit.state.isSignedIn,
    );
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          (previous.user == null) != (current.user == null),
      listener: (context, state) {
        context.read<AppCubit>().setSignedIn(state.user != null);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: switch (isSignedIn) {
        true => const AppTabs(),
        false => const SignInScreen(),
      },
    );
  }
}
