import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/failures/app_failure.dart';
import 'package:flutter_auth_template/core/network/to_network_failure.dart';

import '../../domain/entities/sign_up_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api.dart';
import '../datasources/session_storage.dart';
import '../mappers/user_mapper.dart';
import '../models/sign_up_response_model.dart';

class AuthRepositoryImpl({
  required final AuthApi _authApi,
  required final SessionStorage _sessionStorage,
}) implements AuthRepository {
  @override
  User? get currentUser => _sessionStorage.session?.user.toEntity();

  @override
  Future<User> signIn({required String email, required String password}) async {
    try {
      final session = await _authApi.signIn(email, password);
      await _sessionStorage.save(session);
      return session.user.toEntity();
    } on DioException catch (error) {
      throw _toFailure(error);
    } catch (error) {
      throw UnexpectedFailure(error);
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _authApi.signUp(email, password, {'name': name});
      switch (response) {
        case SignedUpWithSession(:final session):
          await _sessionStorage.save(session);
          return SignedUp(session.user.toEntity());
        case SignUpNeedsConfirmation():
          return const ConfirmationRequired();
      }
    } on DioException catch (error) {
      throw _toFailure(error);
    } catch (error) {
      throw UnexpectedFailure(error);
    }
  }

  @override
  Future<void> signOut() async {
    await _authApi.signOut().onError<DioException>((_, _) {});
    try {
      await _sessionStorage.clear();
    } catch (error) {
      throw UnexpectedFailure(error);
    }
  }

  AppFailure _toFailure(DioException error) {
    if (error.toNetworkFailure() case final network?) return network;
    final type = switch (error.response?.data) {
      {'error_code': final code} => AuthFailureType.fromCode(code),
      _ => null,
    };
    return type == null ? UnexpectedFailure(error) : AuthFailure(type, error);
  }
}
