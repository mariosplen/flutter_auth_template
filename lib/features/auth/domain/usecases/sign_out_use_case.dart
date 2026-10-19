import 'package:flutter_auth_template/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase(final AuthRepository _repository) {
  Future<void> call() => _repository.signOut();
}
