import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/session_model.dart';

/// Saves the session in secure storage and keeps a copy in memory, so the
/// token can be read without waiting on storage.
class SessionLocalDataSource(final FlutterSecureStorage _storage) {
  static const _key = 'session';

  SessionModel? _session;

  SessionModel? get session => _session;

  Future<void> load() async {
    try {
      final json = await _storage.read(key: _key);
      _session = json == null
          ? null
          : SessionModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      // Unreadable session, so start signed out.
    }
  }

  Future<void> save(SessionModel session) async {
    _session = session;
    await _storage.write(key: _key, value: jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    _session = null;
    await _storage.delete(key: _key);
  }
}
