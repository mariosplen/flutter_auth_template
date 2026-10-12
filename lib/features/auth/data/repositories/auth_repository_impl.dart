import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/sign_up_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/session_storage.dart';
import '../mappers/user_mapper.dart';
import '../models/sign_up_response_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl({
  required final AuthRemoteDataSource _remoteDataSource,
  required final SessionStorage _sessionStorage,
}) implements AuthRepository {
  @override
  User? get currentUser => _sessionStorage.session?.user.toEntity();

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      await _sessionStorage.save(session);
      return Result.ok(session.user.toEntity());
    } on Failure catch (failure) {
      return Result.error(failure);
    } catch (error) {
      return Result.error(GenericFailure(error));
    }
  }

  @override
  Future<Result<SignUpResult>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _remoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
      );
      switch (response) {
        case SignedUpWithSession(:final session):
          await _sessionStorage.save(session);
          return Result.ok(SignedUp(session.user.toEntity()));
        case SignUpNeedsConfirmation():
          return const Result.ok(ConfirmationRequired());
      }
    } on Failure catch (failure) {
      return Result.error(failure);
    } catch (error) {
      return Result.error(GenericFailure(error));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (_) {
      // sign out locally regardless
    }
    try {
      await _sessionStorage.clear();
    } catch (_) {
      // already signed out in memory
    }
  }
}
