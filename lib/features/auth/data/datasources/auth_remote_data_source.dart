import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/network/dio_exception_mapper.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_response_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_auth_template/features/auth/domain/failures/auth_failure.dart';

class AuthRemoteDataSource(final AuthApi _authApi) {
  Future<SessionResponseModel> signIn({
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
      throw error.toFailure();
    }
  }

  Failure _toFailure(DioException error) {
    final type = _failureType(error.response?.data);
    return type == null ? error.toFailure() : AuthFailure(type, error);
  }

  AuthFailureType? _failureType(Object? data) => switch (data) {
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
}
