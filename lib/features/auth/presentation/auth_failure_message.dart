import 'package:flutter_auth_template/core/error/failure_message.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/l10n/app_localizations.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';

extension AuthFailureMessage on Failure {
  String authMessage(AppLocalizations l10n) => switch (this) {
    AuthFailure(:final type) => switch (type) {
      .emailAddressInvalid => l10n.errorEmailAddressInvalid,
      .validationFailed => l10n.errorValidationFailed,
      .invalidCredentials => l10n.errorInvalidCredentials,
      .emailNotConfirmed => l10n.errorEmailNotConfirmed,
      .userAlreadyExists => l10n.errorUserAlreadyExists,
      .weakPassword => l10n.errorWeakPassword,
      .overRequestRateLimit => l10n.errorOverRequestRateLimit,
      .overEmailSendRateLimit => l10n.errorOverEmailSendRateLimit,
    },
    _ => message(l10n),
  };
}
