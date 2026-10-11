import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase(final AuthRepository _repository) {
  Future<User> call({required String email, required String password}) =>
      _repository.signIn(email: email, password: password);
}
