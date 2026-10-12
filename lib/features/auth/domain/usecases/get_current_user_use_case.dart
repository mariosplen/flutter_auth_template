import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUserUseCase(final AuthRepository _repository) {
  User? call() => _repository.currentUser;
}
