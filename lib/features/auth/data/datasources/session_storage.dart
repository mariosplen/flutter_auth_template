import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../models/session_model.dart';

@lazySingleton
class SessionStorage(final FlutterSecureStorage _storage) {
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
      // unreadable session, starting signed out
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
