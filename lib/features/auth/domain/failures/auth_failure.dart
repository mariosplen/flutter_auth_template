import 'package:flutter_auth_template/core/failures/app_failure.dart';

enum const AuthFailureType(final String code) {
  emailAddressInvalid('email_address_invalid'),
  validationFailed('validation_failed'),
  invalidCredentials('invalid_credentials'),
  emailNotConfirmed('email_not_confirmed'),
  userAlreadyExists('user_already_exists'),
  weakPassword('weak_password'),
  overRequestRateLimit('over_request_rate_limit'),
  overEmailSendRateLimit('over_email_send_rate_limit');

  static AuthFailureType? fromCode(Object? code) =>
      values.where((type) => type.code == code).firstOrNull;
}

class const AuthFailure(final AuthFailureType type, super.cause)
    extends AppFailure;
