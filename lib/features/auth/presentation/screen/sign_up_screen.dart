import 'package:flutter/material.dart';
import 'package:flutter_auth_template/core/l10n/build_context_extensions.dart';
import 'package:flutter_auth_template/features/auth/domain/validators/credential_validators.dart';
import 'package:flutter_auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  bool get _isFilled =>
      _name.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _password.text.isNotEmpty;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthCubit>().signUp(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthCubit, bool>(
      (cubit) => cubit.state.isLoading,
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createAccount)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            autovalidateMode: .onUnfocus,
            // lets password managers fill in and save the new credentials
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  TextField(
                    controller: _name,
                    textCapitalization: .words,
                    textInputAction: .next,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(labelText: context.l10n.name),
                  ),
                  const SizedBox(height: 16),
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
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    textInputAction: .done,
                    autofillHints: const [AutofillHints.newPassword],
                    autovalidateMode: .onUserInteractionIfError,
                    decoration: InputDecoration(
                      labelText: context.l10n.password,
                    ),
                    validator: (password) =>
                        password!.isEmpty || isLongEnoughPassword(password)
                        ? null
                        : context.l10n.errorPasswordTooShort(minPasswordLength),
                    onFieldSubmitted: (_) async {
                      if (_isFilled) await _signUp();
                    },
                  ),
                  const SizedBox(height: 24),
                  ListenableBuilder(
                    listenable: Listenable.merge([_name, _email, _password]),
                    builder: (context, _) => FilledButton(
                      onPressed: isLoading || !_isFilled ? null : _signUp,
                      child: isLoading
                          ? SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: context.l10n.createAccount,
                              ),
                            )
                          : Text(context.l10n.createAccount),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
