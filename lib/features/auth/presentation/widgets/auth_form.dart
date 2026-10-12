import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/async_value.dart';
import '../../../../core/error/failure_message.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/l10n/build_context_extensions.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/validators/credential_validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class const AuthForm({
  super.key,
  required final String submitLabel,
  required final void Function(String email, String password, String name)
  onSubmit,
  final bool isSignUp = false,
}) extends StatefulWidget {
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
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
      listenWhen: (previous, current) =>
          _status(previous) != _status(current) &&
          (ModalRoute.isCurrentOf(context) ?? false),
      listener: (context, state) {
        if (_status(state) case AsyncError(:final failure)) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(_failureMessage(failure))));
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: .onUnfocus,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            if (widget.isSignUp) ...[
              TextField(
                controller: _name,
                textCapitalization: .words,
                decoration: InputDecoration(labelText: context.l10n.name),
              ),
              const SizedBox(height: 16),
            ],
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
              decoration: InputDecoration(labelText: context.l10n.password),
              validator: (password) =>
                  !widget.isSignUp ||
                      password!.isEmpty ||
                      isLongEnoughPassword(password)
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
                final isMissingInput =
                    email.isEmpty ||
                    password.isEmpty ||
                    (widget.isSignUp && name.isEmpty);
                return FilledButton(
                  onPressed: isLoading || isMissingInput
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            widget.onSubmit(email, password, name);
                          }
                        },
                  child: Text(widget.submitLabel),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AsyncValue<Object?> _status(AuthState state) =>
      widget.isSignUp ? state.signUp : state.signIn;

  String _failureMessage(Failure failure) => switch (failure) {
    AuthFailure(:final type) => switch (type) {
      .emailAddressInvalid => context.l10n.errorEmailAddressInvalid,
      .validationFailed => context.l10n.errorValidationFailed,
      .invalidCredentials => context.l10n.errorInvalidCredentials,
      .emailNotConfirmed => context.l10n.errorEmailNotConfirmed,
      .userAlreadyExists => context.l10n.errorUserAlreadyExists,
      .weakPassword => context.l10n.errorWeakPassword,
      .overRequestRateLimit => context.l10n.errorOverRequestRateLimit,
      .overEmailSendRateLimit => context.l10n.errorOverEmailSendRateLimit,
    },
    _ => failure.message(context.l10n),
  };
}
