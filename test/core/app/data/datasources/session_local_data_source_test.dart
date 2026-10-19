import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_auth_template/core/app/data/datasources/session_local_data_source.dart';
import 'package:flutter_auth_template/core/app/data/models/session_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage;

void main() {
  late SessionLocalDataSource dataSource;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    dataSource = SessionLocalDataSource(mockFlutterSecureStorage);
  });

  const tKey = 'session';
  const tAccessToken = 'test-access-token';
  const tRefreshToken = 'test-refresh-token';

  void setUpMockSecureStorageRead(String? value) {
    when(() => mockFlutterSecureStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => value);
  }

  void setUpMockSecureStorageWriteAndDelete() {
    when(
      () => mockFlutterSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockFlutterSecureStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
  }

  group('session', () {
    test(
      '''
      GIVEN a session local data source that has not loaded anything yet
      WHEN its session is read
      THEN there is no session''',
      () {
        // when
        final result = dataSource.session;
        // then
        expect(result, isNull);
      },
    );
  });

  group('load', () {
    test(
      '''
      GIVEN secure storage holds a session that was saved on an earlier launch
      WHEN the session is loaded
      THEN secure storage is read under the "session" key
      AND the session in memory has the saved access token and refresh token''',
      () async {
        // given
        setUpMockSecureStorageRead(fixture('session_cached.json'));
        // when
        await dataSource.load();
        // then
        verify(() => mockFlutterSecureStorage.read(key: tKey));
        expect(
          dataSource.session,
          isA<SessionModel>()
              .having((s) => s.accessToken, 'accessToken', tAccessToken)
              .having((s) => s.refreshToken, 'refreshToken', tRefreshToken),
        );
      },
    );

    test(
      '''
      GIVEN secure storage holds no session, like on the very first launch
      WHEN the session is loaded
      THEN there is no session in memory, so the user starts signed out''',
      () async {
        // given
        setUpMockSecureStorageRead(null);
        // when
        await dataSource.load();
        // then
        expect(dataSource.session, isNull);
      },
    );

    test(
      '''
      GIVEN secure storage holds a value that is not a valid session JSON
      WHEN the session is loaded
      THEN loading completes without throwing
      AND there is no session in memory, so the user starts signed out''',
      () async {
        // given
        setUpMockSecureStorageRead('not a session');
        // when
        await dataSource.load();
        // then
        expect(dataSource.session, isNull);
      },
    );

    test(
      '''
      GIVEN secure storage cannot be read, like after the keychain was reset
      WHEN the session is loaded
      THEN loading completes without throwing
      AND there is no session in memory, so the user starts signed out''',
      () async {
        // given
        when(() => mockFlutterSecureStorage.read(key: any(named: 'key')))
            .thenThrow(PlatformException(code: 'unreadable'));
        // when
        await dataSource.load();
        // then
        expect(dataSource.session, isNull);
      },
    );
  });

  group('save', () {
    final tSessionModel = SessionModel(
      accessToken: tAccessToken,
      refreshToken: tRefreshToken,
    );

    test(
      '''
      GIVEN a session that the user just got by signing in
      WHEN the session is saved
      THEN the session is written to secure storage as JSON under the
           "session" key
      AND the same session is kept in memory''',
      () async {
        // given
        setUpMockSecureStorageWriteAndDelete();
        // when
        await dataSource.save(tSessionModel);
        // then
        final expectedJsonString = jsonEncode(tSessionModel.toJson());
        verify(
          () => mockFlutterSecureStorage.write(
            key: tKey,
            value: expectedJsonString,
          ),
        );
        expect(dataSource.session, same(tSessionModel));
      },
    );
  });

  group('clear', () {
    final tSessionModel = SessionModel(
      accessToken: tAccessToken,
      refreshToken: tRefreshToken,
    );

    test(
      '''
      GIVEN a session that was saved earlier
      WHEN the session is cleared, like when the user signs out
      THEN the session is deleted from secure storage under the "session" key
      AND there is no session in memory anymore''',
      () async {
        // given
        setUpMockSecureStorageWriteAndDelete();
        await dataSource.save(tSessionModel);
        // when
        await dataSource.clear();
        // then
        verify(() => mockFlutterSecureStorage.delete(key: tKey));
        expect(dataSource.session, isNull);
      },
    );
  });
}
