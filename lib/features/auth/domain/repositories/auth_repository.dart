import 'package:flutter_auth_template/core/error/result.dart';

import '../entities/sign_up_result.dart';

abstract interface class AuthRepository {
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  Future<Result<SignUpResult>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();
}
