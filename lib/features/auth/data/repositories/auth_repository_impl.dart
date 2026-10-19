import 'package:flutter_auth_template/core/app/data/mappers/session_mapper.dart';
import 'package:flutter_auth_template/core/app/domain/repositories/session_repository.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_auth_template/features/auth/domain/entities/sign_up_result.dart';
import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl({
  required final AuthRemoteDataSource _remoteDataSource,
  required final SessionRepository _sessionRepository,
}) implements AuthRepository {
  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      await _sessionRepository.save(session.toEntity());
      return const Result.ok(null);
    } on Failure catch (failure) {
      return Result.error(failure);
    } on Object catch (error) {
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
          await _sessionRepository.save(session.toEntity());
          return const Result.ok(SignedUp());
        case SignUpNeedsConfirmation():
          return const Result.ok(ConfirmationRequired());
      }
    } on Failure catch (failure) {
      return Result.error(failure);
    } on Object catch (error) {
      return Result.error(GenericFailure(error));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } on Object {
      // Sign out locally regardless.
    }
    try {
      await _sessionRepository.clear();
    } on Object {
      // Already signed out in memory.
    }
  }
}
