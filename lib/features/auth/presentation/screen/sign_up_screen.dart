import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/async_value.dart';
import '../../../../core/l10n/build_context_extensions.dart';
import '../../domain/entities/sign_up_result.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_form.dart';

class const SignUpScreen({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, current) => switch (current.signUp) {
        AsyncData(value: ConfirmationRequired()) => true,
        _ => false,
      },
      listener: (context, _) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.confirmEmail)));
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.createAccount)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AuthForm(
              submitLabel: context.l10n.createAccount,
              isSignUp: true,
              onSubmit: (email, password, name) => context
                  .read<AuthCubit>()
                  .signUp(email: email, password: password, name: name),
            ),
          ],
        ),
      ),
    );
  }
}
