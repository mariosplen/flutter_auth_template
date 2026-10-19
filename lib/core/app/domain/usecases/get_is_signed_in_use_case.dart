import 'package:flutter_auth_template/core/app/domain/repositories/session_repository.dart';

class GetIsSignedInUseCase(final SessionRepository _repository) {
  bool call() => _repository.session != null;
}
