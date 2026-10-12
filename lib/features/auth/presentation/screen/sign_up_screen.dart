import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/async_value.dart';
import '../../../../core/l10n/build_context_extensions.dart';
import '../../domain/entities/sign_up_result.dart';
import '../../domain/validators/credential_validators.dart';
import '../auth_failure_message.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class const SignUpScreen({super.key}) extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select(
      (AuthCubit cubit) => cubit.state.isLoading,
    );
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.signUp != current.signUp,
      listener: (context, state) {
        switch (state.signUp) {
          case AsyncData(value: ConfirmationRequired()):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(context.l10n.confirmEmail)));
            Navigator.of(context).pop();
          case AsyncError(:final failure):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.authMessage(context.l10n))),
            );
          case _:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.createAccount)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Form(
              key: _formKey,
              autovalidateMode: .onUnfocus,
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  TextField(
                    controller: _name,
                    textCapitalization: .words,
                    decoration: InputDecoration(labelText: context.l10n.name),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    keyboardType: .emailAddress,
                    autovalidateMode: .onUserInteractionIfError,
                    decoration: InputDecoration(labelText: context.l10n.email),
                    validator: (value) {
                      final email = value!.trim();
                      return email.isEmpty || isValidEmail(email)
                          ? null
                          : context.l10n.errorInvalidEmail;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autovalidateMode: .onUserInteractionIfError,
                    decoration: InputDecoration(
                      labelText: context.l10n.password,
                    ),
                    validator: (password) =>
                        password!.isEmpty || isLongEnoughPassword(password)
                        ? null
                        : context.l10n.errorPasswordTooShort(minPasswordLength),
                  ),
                  const SizedBox(height: 24),
                  ListenableBuilder(
                    listenable: Listenable.merge([_name, _email, _password]),
                    builder: (context, _) {
                      final name = _name.text.trim();
                      final email = _email.text.trim();
                      final password = _password.text;
                      return FilledButton(
                        onPressed:
                            isLoading ||
                                name.isEmpty ||
                                email.isEmpty ||
                                password.isEmpty
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().signUp(
                                    email: email,
                                    password: password,
                                    name: name,
                                  );
                                }
                              },
                        child: Text(context.l10n.createAccount),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
