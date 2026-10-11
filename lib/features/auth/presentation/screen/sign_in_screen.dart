import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_form.dart';
import 'sign_up_screen.dart';

class const SignInScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (AuthCubit cubit) => cubit.state.isLoading,
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.signIn)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AuthForm(
            submitLabel: context.l10n.signIn,
            onSubmit: (email, password, _) => context.read<AuthCubit>().signIn(
              email: email,
              password: password,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: isLoading
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SignUpScreen(),
                    ),
                  ),
            child: Text(context.l10n.createAccount),
          ),
        ],
      ),
    );
  }
}
