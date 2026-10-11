import '../entities/sign_up_result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  User? get currentUser;

  Future<User> signIn({required String email, required String password});

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();
}
