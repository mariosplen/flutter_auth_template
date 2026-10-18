import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_auth_template/core/error/failures.dart';

import '../../domain/failures/auth_failure.dart';
import '../models/sign_up_response_model.dart';
import 'auth_api.dart';

class AuthRemoteDataSource(final AuthApi _authApi) {
  Future<SessionModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _authApi.signIn(email, password);
    } on DioException catch (error) {
      throw _toFailure(error);
    }
  }

  Future<SignUpResponseModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      return await _authApi.signUp(email, password, {'name': name});
    } on DioException catch (error) {
      throw _toFailure(error);
    }
  }

  Future<void> signOut() async {
    try {
      await _authApi.signOut();
    } on DioException catch (error) {
      throw ServerFailure(error);
    }
  }

  Failure _toFailure(DioException error) {
    final AuthFailureType? type = switch (error.response?.data) {
      {'error_code': final code} => switch (code) {
        'email_address_invalid' => .emailAddressInvalid,
        'validation_failed' => .validationFailed,
        'invalid_credentials' => .invalidCredentials,
        'email_not_confirmed' => .emailNotConfirmed,
        'user_already_exists' => .userAlreadyExists,
        'weak_password' => .weakPassword,
        'over_request_rate_limit' => .overRequestRateLimit,
        'over_email_send_rate_limit' => .overEmailSendRateLimit,
        _ => null,
      },
      _ => null,
    };
    return type == null ? ServerFailure(error) : AuthFailure(type, error);
  }
}
