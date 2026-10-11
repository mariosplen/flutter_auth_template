import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase(final AuthRepository _repository) {
  User? call() => _repository.currentUser;
}
