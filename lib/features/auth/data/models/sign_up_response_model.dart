import 'package:flutter_auth_template/core/app/data/models/session_model.dart';

sealed class const SignUpResponseModel() {
  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) =>
      switch (json) {
        {'access_token': String()} => SignedUpWithSession(
          SessionModel.fromJson(json),
        ),
        _ => const SignUpNeedsConfirmation(),
      };
}

final class const SignedUpWithSession(final SessionModel session)
    extends SignUpResponseModel;

final class const SignUpNeedsConfirmation() extends SignUpResponseModel;
