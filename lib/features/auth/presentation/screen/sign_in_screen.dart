import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/features/auth/domain/validators/credential_validators.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_auth_template/features/auth/presentation/screen/sign_up_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  bool get _isFilled =>
      _email.text.trim().isNotEmpty && _password.text.isNotEmpty;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthCubit>().signIn(
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isLoading,
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.signIn)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            autovalidateMode: .onUnfocus,
            // lets password managers fill in and save the credentials
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: .emailAddress,
                    textInputAction: .next,
                    autofillHints: const [AutofillHints.email],
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
                    textInputAction: .done,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: context.l10n.password,
                    ),
                    onSubmitted: (_) async {
                      if (_isFilled) await _signIn();
                    },
                  ),
                  const SizedBox(height: 24),
                  ListenableBuilder(
                    listenable: Listenable.merge([_email, _password]),
                    builder: (context, _) => FilledButton(
                      onPressed: isLoading || !_isFilled ? null : _signIn,
                      child: isLoading
                          ? SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: context.l10n.signIn,
                              ),
                            )
                          : Text(context.l10n.signIn),
                    ),
                  ),
                ],
              ),
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
