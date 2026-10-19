import 'package:flutter_auth_template/core/error/result.dart';

import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase(final AuthRepository _repository) {
  Future<Result<void>> call({
    required String email,
    required String password,
  }) => _repository.signIn(email: email, password: password);
}
