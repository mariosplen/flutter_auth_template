import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/build_context_extensions.dart';
import '../../domain/validators/credential_validators.dart';
import '../cubit/auth_cubit.dart';
import 'sign_up_screen.dart';

class const SignInScreen({super.key}) extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

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
          Form(
            key: _formKey,
            autovalidateMode: .onUnfocus,
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
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
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: context.l10n.password),
                ),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: Listenable.merge([_email, _password]),
                  builder: (context, _) {
                    final email = _email.text.trim();
                    final password = _password.text;
                    return FilledButton(
                      onPressed: isLoading || email.isEmpty || password.isEmpty
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().signIn(
                                  email: email,
                                  password: password,
                                );
                              }
                            },
                      child: Text(context.l10n.signIn),
                    );
                  },
                ),
              ],
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
