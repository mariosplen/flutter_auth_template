import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_local_data_source.dart';
import '../mappers/session_mapper.dart';

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
