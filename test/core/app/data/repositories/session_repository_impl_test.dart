import 'package:flutter_auth_template/core/app/data/datasources/session_local_data_source.dart';
import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_auth_template/core/app/data/repositories/session_repository_impl.dart';
import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionLocalDataSource extends Mock implements SessionLocalDataSource;

void main() {
  late SessionRepositoryImpl repository;
  late MockSessionLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(SessionModel(accessToken: '', refreshToken: ''));
  });

  setUp(() {
    mockLocalDataSource = MockSessionLocalDataSource();
    repository = SessionRepositoryImpl(mockLocalDataSource);
  });

  const tAccessToken = 'test-access-token';
  const tRefreshToken = 'test-refresh-token';
  const tSession = Session(
    accessToken: tAccessToken,
    refreshToken: tRefreshToken,
  );
  final tSessionModel = SessionModel(
    accessToken: tAccessToken,
    refreshToken: tRefreshToken,
  );

  group('session', () {
    test(
      '''
      GIVEN the local data source holds a session in memory
      WHEN the session is read from the repository
      THEN the repository returns it as a session entity with the same tokens''',
      () {
        // given
        when(() => mockLocalDataSource.session).thenReturn(tSessionModel);
        // when
        final result = repository.session;
        // then
        expect(result, tSession);
      },
    );

    test(
      '''
      GIVEN the local data source holds no session, because the user is
            signed out
      WHEN the session is read from the repository
      THEN the repository returns no session''',
      () {
        // given
        when(() => mockLocalDataSource.session).thenReturn(null);
        // when
        final result = repository.session;
        // then
        expect(result, isNull);
      },
    );
  });

  group('load', () {
    test(
      '''
      GIVEN a session repository
      WHEN the session is loaded
      THEN the local data source is asked to load the stored session
      AND nothing else is asked of the local data source''',
      () async {
        // given
        when(() => mockLocalDataSource.load()).thenAnswer((_) async {});
        // when
        await repository.load();
        // then
        verify(() => mockLocalDataSource.load()).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      },
    );
  });

  group('save', () {
    test(
      '''
      GIVEN a session entity that the user just got by signing in
      WHEN the session is saved
      THEN the local data source saves it as a session model with the same
           access token and refresh token''',
      () async {
        // given
        when(() => mockLocalDataSource.save(any())).thenAnswer((_) async {});
        // when
        await repository.save(tSession);
        // then
        final saved =
            verify(() => mockLocalDataSource.save(captureAny())).captured.single
                as SessionModel;
        expect(saved.accessToken, tAccessToken);
        expect(saved.refreshToken, tRefreshToken);
      },
    );
  });

  group('clear', () {
    test(
      '''
      GIVEN a session repository
      WHEN the session is cleared, like when the user signs out
      THEN the local data source is asked to clear the session
      AND nothing else is asked of the local data source''',
      () async {
        // given
        when(() => mockLocalDataSource.clear()).thenAnswer((_) async {});
        // when
        await repository.clear();
        // then
        verify(() => mockLocalDataSource.clear()).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      },
    );
  });
}
