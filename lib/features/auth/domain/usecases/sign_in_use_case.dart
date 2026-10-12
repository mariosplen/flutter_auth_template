import 'package:flutter_auth_template/core/error/result.dart';
import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SignInUseCase(final AuthRepository _repository) {
  Future<Result<User>> call({
    required String email,
    required String password,
  }) => _repository.signIn(email: email, password: password);
}
