import 'package:flutter_auth_template/core/error/result.dart';

import '../entities/sign_up_result.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase(final AuthRepository _repository) {
  Future<Result<SignUpResult>> call({
    required String email,
    required String password,
    required String name,
  }) => _repository.signUp(email: email, password: password, name: name);
}
