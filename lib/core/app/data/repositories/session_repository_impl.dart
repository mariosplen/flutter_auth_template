import 'package:flutter_auth_template/core/app/data/datasources/session_local_data_source.dart';
import 'package:flutter_auth_template/core/app/data/mappers/session_mapper.dart';
import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_auth_template/core/app/domain/repositories/session_repository.dart';

class SessionRepositoryImpl(final SessionLocalDataSource _localDataSource)
    implements SessionRepository {
  @override
  Session? get session => _localDataSource.session?.toEntity();

  @override
  Future<void> load() => _localDataSource.load();

  @override
  Future<void> save(Session session) =>
      _localDataSource.save(session.toModel());

  @override
  Future<void> clear() => _localDataSource.clear();
}
