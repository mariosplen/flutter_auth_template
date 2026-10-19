import 'package:flutter_auth_template/core/app/domain/entities/session.dart';

/// The current session, kept in memory and in secure storage.
abstract interface class SessionRepository {
  /// Null when signed out. It's read synchronously on every request, so
  /// [load] has to run before the app starts.
  Session? get session;

  /// Reads the stored session into memory.
  Future<void> load();

  Future<void> save(Session session);

  Future<void> clear();
}
