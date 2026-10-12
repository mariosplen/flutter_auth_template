import 'package:flutter_auth_template/core/error/result.dart';

import '../entities/sign_up_result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  User? get currentUser;

  Future<Result<User>> signIn({
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
