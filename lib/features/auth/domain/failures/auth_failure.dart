import 'package:flutter_auth_template/core/error/failures.dart';

enum AuthFailureType {
  emailAddressInvalid,
  validationFailed,
  invalidCredentials,
  emailNotConfirmed,
  userAlreadyExists,
  weakPassword,
  overRequestRateLimit,
  overEmailSendRateLimit,
}

class const AuthFailure(final AuthFailureType type, super.cause)
    extends Failure {
  @override
  List<Object?> get props => [type, cause];
}
