import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@lazySingleton
class SignOutUseCase(final AuthRepository _repository) {
  Future<void> call() => _repository.signOut();
}
