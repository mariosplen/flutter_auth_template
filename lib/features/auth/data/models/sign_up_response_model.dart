import 'package:flutter_auth_template/features/auth/data/models/session_response_model.dart';

sealed class const SignUpResponseModel() {
  factory fromJson(Map<String, dynamic> json) => switch (json) {
    {'access_token': String()} => SignedUpWithSession(
      SessionResponseModel.fromJson(json),
    ),
    _ => const SignUpNeedsConfirmation(),
  };
}

final class const SignedUpWithSession(final SessionResponseModel session)
    extends SignUpResponseModel;

final class const SignUpNeedsConfirmation() extends SignUpResponseModel;
