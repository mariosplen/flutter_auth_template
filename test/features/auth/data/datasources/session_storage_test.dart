import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/session_storage.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late SessionStorage sessionStorage;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    sessionStorage = SessionStorage(mockFlutterSecureStorage);
  });

  const tKey = 'session';
  final tSessionModel = SessionModel(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    user: UserModel(
      id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
      email: 'test@example.com',
    ),
  );

  void setUpMockFlutterSecureStorageRead(String? stored) {
    when(() => mockFlutterSecureStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => stored);
  }

  void setUpMockFlutterSecureStorageWriteSuccess() {
    when(
      () => mockFlutterSecureStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
  }

  void setUpMockFlutterSecureStorageDeleteSuccess() {
    when(() => mockFlutterSecureStorage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
  }

  group('session', () {
    test(
      '''
      GIVEN a session storage that was just created
      WHEN the session is read before anything was loaded or saved
      THEN there is no session''',
      () {
        // when
        final session = sessionStorage.session;

        // then
        expect(session, isNull);
        verifyZeroInteractions(mockFlutterSecureStorage);
      },
    );
  });

  group('load', () {
    test(
      '''
      GIVEN the secure storage holds the JSON of a session
      WHEN load is called
      THEN the session is read from the secure storage under the "session" key
      AND the session is kept in memory with its tokens and its user''',
      () async {
        // given
        setUpMockFlutterSecureStorageRead(fixture('session.json'));

        // when
        await sessionStorage.load();

        // then
        verify(() => mockFlutterSecureStorage.read(key: tKey)).called(1);
        final session = sessionStorage.session;
        expect(session, isNotNull);
        expect(session!.accessToken, 'test-access-token');
        expect(session.refreshToken, 'test-refresh-token');
        expect(session.user.id, '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f');
        expect(session.user.email, 'test@example.com');
      },
    );

    test(
      '''
      GIVEN the secure storage holds nothing, as on the first launch
      WHEN load is called
      THEN there is no session''',
      () async {
        // given
        setUpMockFlutterSecureStorageRead(null);

        // when
        await sessionStorage.load();

        // then
        verify(() => mockFlutterSecureStorage.read(key: tKey)).called(1);
        expect(sessionStorage.session, isNull);
      },
    );

    test(
      '''
      GIVEN the secure storage holds something that is not the JSON of a session
      WHEN load is called
      THEN it completes without throwing
      AND there is no session, so the app starts signed out''',
      () async {
        // given
        setUpMockFlutterSecureStorageRead('not a session');

        // when
        await sessionStorage.load();

        // then
        expect(sessionStorage.session, isNull);
      },
    );

    test(
      '''
      GIVEN the secure storage fails while it is being read
      WHEN load is called
      THEN it completes without throwing
      AND there is no session, so the app starts signed out''',
      () async {
        // given
        when(() => mockFlutterSecureStorage.read(key: any(named: 'key')))
            .thenThrow(PlatformException(code: 'keystore_unavailable'));

        // when
        await sessionStorage.load();

        // then
        expect(sessionStorage.session, isNull);
      },
    );
  });

  group('save', () {
    test(
      '''
      GIVEN a session
      WHEN save is called with it
      THEN the session is available in memory right away
      AND its encoded JSON is written to the secure storage
          under the "session" key''',
      () async {
        // given
        setUpMockFlutterSecureStorageWriteSuccess();

        // when
        await sessionStorage.save(tSessionModel);

        // then
        expect(sessionStorage.session, same(tSessionModel));
        verify(
          () => mockFlutterSecureStorage.write(
            key: tKey,
            value: jsonEncode(tSessionModel.toJson()),
          ),
        ).called(1);
      },
    );

    test(
      '''
      GIVEN a session that was saved
      WHEN what was written to the secure storage is loaded
           by a brand new session storage, as after an app restart
      THEN the new session storage has the same session again''',
      () async {
        // given
        setUpMockFlutterSecureStorageWriteSuccess();
        await sessionStorage.save(tSessionModel);
        final written =
            verify(
                  () => mockFlutterSecureStorage.write(
                    key: tKey,
                    value: captureAny(named: 'value'),
                  ),
                ).captured.single
                as String;
        setUpMockFlutterSecureStorageRead(written);
        final restartedSessionStorage = SessionStorage(
          mockFlutterSecureStorage,
        );

        // when
        await restartedSessionStorage.load();

        // then
        final session = restartedSessionStorage.session;
        expect(session, isNotNull);
        expect(session!.accessToken, tSessionModel.accessToken);
        expect(session.refreshToken, tSessionModel.refreshToken);
        expect(session.user.id, tSessionModel.user.id);
        expect(session.user.email, tSessionModel.user.email);
      },
    );
  });

  group('clear', () {
    test(
      '''
      GIVEN a session storage that holds a saved session
      WHEN clear is called
      THEN there is no session in memory any more
      AND the "session" key is deleted from the secure storage''',
      () async {
        // given
        setUpMockFlutterSecureStorageWriteSuccess();
        setUpMockFlutterSecureStorageDeleteSuccess();
        await sessionStorage.save(tSessionModel);

        // when
        await sessionStorage.clear();

        // then
        expect(sessionStorage.session, isNull);
        verify(() => mockFlutterSecureStorage.delete(key: tKey)).called(1);
      },
    );

    test(
      '''
      GIVEN a session storage that holds a saved session
      AND the secure storage fails while the key is being deleted
      WHEN clear is called
      THEN the error of the secure storage is thrown
      AND there is still no session in memory any more''',
      () async {
        // given
        final tError = PlatformException(code: 'keystore_unavailable');
        setUpMockFlutterSecureStorageWriteSuccess();
        when(() => mockFlutterSecureStorage.delete(key: any(named: 'key')))
            .thenThrow(tError);
        await sessionStorage.save(tSessionModel);

        // when
        final call = sessionStorage.clear;

        // then
        await expectLater(call, throwsA(same(tError)));
        expect(sessionStorage.session, isNull);
      },
    );
  });
}
