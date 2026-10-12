import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/session_storage.dart';
import 'package:flutter_auth_template/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockAuthApi extends Mock implements AuthApi {}

class MockSessionStorage extends Mock implements SessionStorage {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

abstract class OnSessionExpired {
  void call();
}

class MockOnSessionExpired extends Mock implements OnSessionExpired {}

void main() {
  late AuthInterceptor interceptor;
  late MockDio mockDio;
  late MockAuthApi mockAuthApi;
  late MockSessionStorage mockSessionStorage;
  late MockOnSessionExpired mockOnSessionExpired;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockErrorInterceptorHandler mockErrorHandler;

  setUpAll(() {
    final requestOptions = RequestOptions();
    registerFallbackValue(requestOptions);
    registerFallbackValue(DioException(requestOptions: requestOptions));
    registerFallbackValue(Response<dynamic>(requestOptions: requestOptions));
    registerFallbackValue(
      SessionModel(
        accessToken: '',
        refreshToken: '',
        user: UserModel(id: '', email: ''),
      ),
    );
  });

  setUp(() {
    mockDio = MockDio();
    mockAuthApi = MockAuthApi();
    mockSessionStorage = MockSessionStorage();
    mockOnSessionExpired = MockOnSessionExpired();
    mockRequestHandler = MockRequestInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
    interceptor = AuthInterceptor(
      dio: mockDio,
      authApi: mockAuthApi,
      sessionStorage: mockSessionStorage,
      onSessionExpired: mockOnSessionExpired.call,
    );
  });

  const tAccessToken = 'test-access-token';
  const tRefreshToken = 'test-refresh-token';
  const tFreshAccessToken = 'fresh-access-token';
  final tUserModel = UserModel(
    id: '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f',
    email: 'test@example.com',
  );
  final tSessionModel = SessionModel(
    accessToken: tAccessToken,
    refreshToken: tRefreshToken,
    user: tUserModel,
  );
  final tFreshSessionModel = SessionModel(
    accessToken: tFreshAccessToken,
    refreshToken: 'fresh-refresh-token',
    user: tUserModel,
  );

  void setUpMockSessionStorageSession(SessionModel? session) {
    when(() => mockSessionStorage.session).thenReturn(session);
  }

  RequestOptions buildRequestOptions({
    String? sentWithAccessToken = tAccessToken,
    Map<String, dynamic>? extra,
  }) => RequestOptions(
    path: '/rest/v1/posts',
    headers: {
      if (sentWithAccessToken != null)
        'Authorization': 'Bearer $sentWithAccessToken',
    },
    extra: extra,
  );

  DioException buildDioException(
    RequestOptions requestOptions, {
    int? statusCode,
    Object? data,
  }) => DioException(
    requestOptions: requestOptions,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: data,
          ),
  );

  DioException buildRefreshDioException({int? statusCode}) => buildDioException(
    RequestOptions(path: '/auth/v1/token?grant_type=refresh_token'),
    statusCode: statusCode,
  );

  Response<dynamic> buildRetriedResponse(RequestOptions requestOptions) =>
      Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: <dynamic>[],
      );

  group('onRequest', () {
    test(
      '''
      GIVEN the session storage holds a session
      AND a request that does not say anything about needing authentication
      WHEN the request passes through the interceptor
      THEN the access token of the session is added to the request
           as a "Bearer" Authorization header
      AND the request is passed on''',
      () {
        // given
        setUpMockSessionStorageSession(tSessionModel);
        final tRequestOptions = buildRequestOptions(sentWithAccessToken: null);

        // when
        interceptor.onRequest(tRequestOptions, mockRequestHandler);

        // then
        expect(
          tRequestOptions.headers['Authorization'],
          'Bearer $tAccessToken',
        );
        verify(() => mockRequestHandler.next(tRequestOptions)).called(1);
      },
    );

    test(
      '''
      GIVEN the session storage holds a session
      AND a request that is marked as not requiring authentication,
          like the sign in request
      WHEN the request passes through the interceptor
      THEN no Authorization header is added to the request
      AND the request is passed on''',
      () {
        // given
        setUpMockSessionStorageSession(tSessionModel);
        final tRequestOptions = buildRequestOptions(
          sentWithAccessToken: null,
          extra: {requiresAuthKey: false},
        );

        // when
        interceptor.onRequest(tRequestOptions, mockRequestHandler);

        // then
        expect(tRequestOptions.headers.containsKey('Authorization'), isFalse);
        verify(() => mockRequestHandler.next(tRequestOptions)).called(1);
      },
    );

    test(
      '''
      GIVEN the session storage holds no session, because nobody is signed in
      WHEN a request passes through the interceptor
      THEN no Authorization header is added to the request
      AND the request is passed on''',
      () {
        // given
        setUpMockSessionStorageSession(null);
        final tRequestOptions = buildRequestOptions(sentWithAccessToken: null);

        // when
        interceptor.onRequest(tRequestOptions, mockRequestHandler);

        // then
        expect(tRequestOptions.headers.containsKey('Authorization'), isFalse);
        verify(() => mockRequestHandler.next(tRequestOptions)).called(1);
      },
    );
  });

  group('onError', () {
    void setUpMockAuthApiRefreshSessionSuccess() {
      when(() => mockAuthApi.refreshSession(any()))
          .thenAnswer((_) async => tFreshSessionModel);
    }

    void setUpMockAuthApiRefreshSessionThrows(Object error) {
      when(() => mockAuthApi.refreshSession(any())).thenThrow(error);
    }

    void setUpMockSessionStorageSaveSuccess() {
      when(() => mockSessionStorage.save(tFreshSessionModel))
          .thenAnswer((_) async {});
    }

    void setUpMockSessionStorageClearSuccess() {
      when(() => mockSessionStorage.clear()).thenAnswer((_) async {});
    }

    void setUpMockDioFetchSuccess(Response<dynamic> response) {
      when(() => mockDio.fetch<dynamic>(any()))
          .thenAnswer((_) async => response);
    }

    void verifyNothingWasRefreshedOrRetried() {
      verifyNever(() => mockAuthApi.refreshSession(any()));
      verifyNever(() => mockDio.fetch<dynamic>(any()));
    }

    group('errors that are passed on untouched', () {
      test(
        '''
        GIVEN the session storage holds a session
        AND a request that failed with a 500, which is not about authentication
        WHEN the error passes through the interceptor
        THEN the same error is passed on
        AND the session is not refreshed
        AND the request is not retried''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          final tDioException = buildDioException(
            buildRequestOptions(),
            statusCode: 500,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockErrorHandler.next(tDioException)).called(1);
          verifyNothingWasRefreshedOrRetried();
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that never got a response, as when the device is offline
        WHEN the error passes through the interceptor
        THEN the same error is passed on
        AND the session is not refreshed
        AND the request is not retried''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          final tDioException = buildDioException(buildRequestOptions());

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockErrorHandler.next(tDioException)).called(1);
          verifyNothingWasRefreshedOrRetried();
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that failed with a 403 that is not about an expired token,
            like a row that the user is not allowed to read
        WHEN the error passes through the interceptor
        THEN the same error is passed on
        AND the session is not refreshed
        AND the request is not retried''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          final tDioException = buildDioException(
            buildRequestOptions(),
            statusCode: 403,
            data: {'error_code': 'insufficient_privilege'},
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockErrorHandler.next(tDioException)).called(1);
          verifyNothingWasRefreshedOrRetried();
        },
      );

      test(
        '''
        GIVEN the session storage holds no session, because nobody is signed in
        AND a request that failed with a 401
        WHEN the error passes through the interceptor
        THEN the same error is passed on
        AND the session is not refreshed
        AND the request is not retried''',
        () async {
          // given
          setUpMockSessionStorageSession(null);
          final tDioException = buildDioException(
            buildRequestOptions(sentWithAccessToken: null),
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockErrorHandler.next(tDioException)).called(1);
          verifyNothingWasRefreshedOrRetried();
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that is marked as not requiring authentication
            failed with a 401, like a sign in with a wrong password
        WHEN the error passes through the interceptor
        THEN the same error is passed on
        AND the session is not refreshed
        AND the request is not retried''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          final tDioException = buildDioException(
            buildRequestOptions(
              sentWithAccessToken: null,
              extra: {requiresAuthKey: false},
            ),
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockErrorHandler.next(tDioException)).called(1);
          verifyNothingWasRefreshedOrRetried();
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was already retried once failed with a 401 again
        WHEN the error passes through the interceptor
        THEN the same error is passed on
        AND the session is not refreshed
        AND the request is not retried a second time, so there is no loop''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          final tDioException = buildDioException(
            buildRequestOptions(extra: {'retried': true}),
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockErrorHandler.next(tDioException)).called(1);
          verifyNothingWasRefreshedOrRetried();
        },
      );
    });

    group('expired access token', () {
      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was sent with the access token of that session
            failed with a 401
        AND the API answers the refresh with a fresh session
        AND the retried request succeeds
        WHEN the error passes through the interceptor
        THEN the session is refreshed with the refresh token of the session
        AND the fresh session is saved to the session storage
        AND the request is marked as retried and sent again
        AND the error is resolved with the response of the retried request
        AND the app is not told that the session expired''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          setUpMockAuthApiRefreshSessionSuccess();
          setUpMockSessionStorageSaveSuccess();
          final tRequestOptions = buildRequestOptions();
          final tRetriedResponse = buildRetriedResponse(tRequestOptions);
          setUpMockDioFetchSuccess(tRetriedResponse);
          final tDioException = buildDioException(
            tRequestOptions,
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verifyInOrder([
            () => mockAuthApi.refreshSession(tRefreshToken),
            () => mockSessionStorage.save(tFreshSessionModel),
            () => mockDio.fetch<dynamic>(tRequestOptions),
            () => mockErrorHandler.resolve(tRetriedResponse),
          ]);
          expect(tRequestOptions.extra['retried'], isTrue);
          verifyNever(() => mockErrorHandler.next(any()));
          verifyNever(() => mockOnSessionExpired());
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was sent with the access token of that session
            failed with a 403 and the "bad_jwt" error code,
            which is how Supabase Auth answers an expired access token
        AND the API answers the refresh with a fresh session
        AND the retried request succeeds
        WHEN the error passes through the interceptor
        THEN the session is refreshed and saved, just as for a 401
        AND the error is resolved with the response of the retried request''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          setUpMockAuthApiRefreshSessionSuccess();
          setUpMockSessionStorageSaveSuccess();
          final tRequestOptions = buildRequestOptions();
          final tRetriedResponse = buildRetriedResponse(tRequestOptions);
          setUpMockDioFetchSuccess(tRetriedResponse);
          final tDioException = buildDioException(
            tRequestOptions,
            statusCode: 403,
            data: {'code': 403, 'error_code': 'bad_jwt', 'msg': 'invalid JWT'},
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verifyInOrder([
            () => mockAuthApi.refreshSession(tRefreshToken),
            () => mockSessionStorage.save(tFreshSessionModel),
            () => mockDio.fetch<dynamic>(tRequestOptions),
            () => mockErrorHandler.resolve(tRetriedResponse),
          ]);
        },
      );

      test(
        '''
        GIVEN the session storage holds a session that was already refreshed
        AND a request that was still sent with the older access token
            failed with a 401
        AND the retried request succeeds
        WHEN the error passes through the interceptor
        THEN the session is not refreshed a second time
        AND the request is marked as retried and sent again right away
        AND the error is resolved with the response of the retried request''',
        () async {
          // given
          setUpMockSessionStorageSession(tFreshSessionModel);
          final tRequestOptions = buildRequestOptions(
            sentWithAccessToken: tAccessToken,
          );
          final tRetriedResponse = buildRetriedResponse(tRequestOptions);
          setUpMockDioFetchSuccess(tRetriedResponse);
          final tDioException = buildDioException(
            tRequestOptions,
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verifyNever(() => mockAuthApi.refreshSession(any()));
          verify(() => mockDio.fetch<dynamic>(tRequestOptions)).called(1);
          expect(tRequestOptions.extra['retried'], isTrue);
          verify(() => mockErrorHandler.resolve(tRetriedResponse)).called(1);
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was sent with the access token of that session
            failed with a 401
        AND the API answers the refresh with a fresh session
        AND the retried request fails again
        WHEN the error passes through the interceptor
        THEN the session is refreshed and saved
        AND the error of the retried request is passed on,
            instead of the original one''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          setUpMockAuthApiRefreshSessionSuccess();
          setUpMockSessionStorageSaveSuccess();
          final tRequestOptions = buildRequestOptions();
          final tRetriedDioException = buildDioException(
            tRequestOptions,
            statusCode: 500,
          );
          when(() => mockDio.fetch<dynamic>(any()))
              .thenThrow(tRetriedDioException);
          final tDioException = buildDioException(
            tRequestOptions,
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockSessionStorage.save(tFreshSessionModel)).called(1);
          verify(() => mockErrorHandler.next(tRetriedDioException)).called(1);
          verifyNever(() => mockErrorHandler.next(tDioException));
          verifyNever(() => mockErrorHandler.resolve(any()));
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was sent with the access token of that session
            failed with a 401
        AND the user signs out while the session is being refreshed
        AND the retried request succeeds
        WHEN the error passes through the interceptor
        THEN the fresh session is not saved,
             because it would sign the user back in
        AND the request is still sent again''',
        () async {
          // given
          SessionModel? currentSession = tSessionModel;
          when(() => mockSessionStorage.session)
              .thenAnswer((_) => currentSession);
          when(() => mockAuthApi.refreshSession(any())).thenAnswer((_) async {
            currentSession = null;
            return tFreshSessionModel;
          });
          final tRequestOptions = buildRequestOptions();
          final tRetriedResponse = buildRetriedResponse(tRequestOptions);
          setUpMockDioFetchSuccess(tRetriedResponse);
          final tDioException = buildDioException(
            tRequestOptions,
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verify(() => mockAuthApi.refreshSession(tRefreshToken)).called(1);
          verifyNever(() => mockSessionStorage.save(any()));
          verify(() => mockDio.fetch<dynamic>(tRequestOptions)).called(1);
        },
      );
    });

    group('refresh that fails', () {
      for (final tStatusCode in [400, 401, 403]) {
        test(
          '''
          GIVEN the session storage holds a session
          AND a request that was sent with the access token of that session
              failed with a 401
          AND the API rejects the refresh with a $tStatusCode,
              because the refresh token is not valid any more
          WHEN the error passes through the interceptor
          THEN the session storage is cleared
          AND the app is told that the session expired
          AND the error of the refresh is passed on
          AND the request is not retried''',
          () async {
            // given
            setUpMockSessionStorageSession(tSessionModel);
            setUpMockSessionStorageClearSuccess();
            final tRefreshDioException = buildRefreshDioException(
              statusCode: tStatusCode,
            );
            setUpMockAuthApiRefreshSessionThrows(tRefreshDioException);
            final tDioException = buildDioException(
              buildRequestOptions(),
              statusCode: 401,
            );

            // when
            await interceptor.onError(tDioException, mockErrorHandler);

            // then
            verifyInOrder([
              () => mockSessionStorage.clear(),
              () => mockOnSessionExpired(),
              () => mockErrorHandler.next(tRefreshDioException),
            ]);
            verifyNever(() => mockDio.fetch<dynamic>(any()));
            verifyNever(() => mockErrorHandler.resolve(any()));
          },
        );
      }

      for (final tStatusCode in [408, 429, 500]) {
        test(
          '''
          GIVEN the session storage holds a session
          AND a request that was sent with the access token of that session
              failed with a 401
          AND the refresh fails with a $tStatusCode,
              which does not say that the refresh token is invalid
          WHEN the error passes through the interceptor
          THEN the session storage is not cleared, the user stays signed in
          AND the app is not told that the session expired
          AND the error of the refresh is passed on
          AND the request is not retried''',
          () async {
            // given
            setUpMockSessionStorageSession(tSessionModel);
            final tRefreshDioException = buildRefreshDioException(
              statusCode: tStatusCode,
            );
            setUpMockAuthApiRefreshSessionThrows(tRefreshDioException);
            final tDioException = buildDioException(
              buildRequestOptions(),
              statusCode: 401,
            );

            // when
            await interceptor.onError(tDioException, mockErrorHandler);

            // then
            verifyNever(() => mockSessionStorage.clear());
            verifyNever(() => mockOnSessionExpired());
            verify(() => mockErrorHandler.next(tRefreshDioException)).called(1);
            verifyNever(() => mockDio.fetch<dynamic>(any()));
          },
        );
      }

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was sent with the access token of that session
            failed with a 401
        AND the refresh never gets a response, as when the device is offline
        WHEN the error passes through the interceptor
        THEN the session storage is not cleared, the user stays signed in
        AND the app is not told that the session expired
        AND the error of the refresh is passed on
        AND the request is not retried''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          final tRefreshDioException = buildRefreshDioException();
          setUpMockAuthApiRefreshSessionThrows(tRefreshDioException);
          final tDioException = buildDioException(
            buildRequestOptions(),
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verifyNever(() => mockSessionStorage.clear());
          verifyNever(() => mockOnSessionExpired());
          verify(() => mockErrorHandler.next(tRefreshDioException)).called(1);
          verifyNever(() => mockDio.fetch<dynamic>(any()));
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was sent with the access token of that session
            failed with a 401
        AND the user signs in again while the session is being refreshed
        AND the API rejects the refresh of the older session with a 400
        WHEN the error passes through the interceptor
        THEN the session storage is not cleared,
             because it holds the newer session by now
        AND the app is not told that the session expired
        AND the error of the refresh is passed on''',
        () async {
          // given
          SessionModel? currentSession = tSessionModel;
          when(() => mockSessionStorage.session)
              .thenAnswer((_) => currentSession);
          final tRefreshDioException = buildRefreshDioException(
            statusCode: 400,
          );
          when(() => mockAuthApi.refreshSession(any())).thenAnswer((_) async {
            currentSession = tFreshSessionModel;
            throw tRefreshDioException;
          });
          final tDioException = buildDioException(
            buildRequestOptions(),
            statusCode: 401,
          );

          // when
          await interceptor.onError(tDioException, mockErrorHandler);

          // then
          verifyNever(() => mockSessionStorage.clear());
          verifyNever(() => mockOnSessionExpired());
          verify(() => mockErrorHandler.next(tRefreshDioException)).called(1);
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a request that was sent with the access token of that session
            failed with a 401
        AND the API rejects the refresh with a 400
        AND the session storage fails while it is being cleared
        WHEN the error passes through the interceptor
        THEN the app is told that the session expired all the same
        AND the error of the session storage is thrown''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          final tStorageError = PlatformException(code: 'keystore_unavailable');
          when(() => mockSessionStorage.clear()).thenThrow(tStorageError);
          setUpMockAuthApiRefreshSessionThrows(
            buildRefreshDioException(statusCode: 400),
          );
          final tDioException = buildDioException(
            buildRequestOptions(),
            statusCode: 401,
          );

          // when
          final onError = interceptor.onError(tDioException, mockErrorHandler);

          // then
          await expectLater(onError, throwsA(same(tStorageError)));
          verify(() => mockOnSessionExpired()).called(1);
        },
      );
    });

    group('several requests at the same time', () {
      test(
        '''
        GIVEN the session storage holds a session
        AND two requests that were sent with the access token of that session
            both failed with a 401
        AND the refresh is still on its way when the second error arrives
        WHEN both errors pass through the interceptor
        THEN the session is refreshed only once for the two of them
        AND both requests are sent again after the refresh
        AND both errors are resolved with the response of their own request''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          setUpMockSessionStorageSaveSuccess();
          final tRefreshCompleter = Completer<SessionModel>();
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) => tRefreshCompleter.future);
          final tFirstRequestOptions = buildRequestOptions();
          final tSecondRequestOptions = buildRequestOptions();
          final tFirstRetriedResponse = buildRetriedResponse(
            tFirstRequestOptions,
          );
          final tSecondRetriedResponse = buildRetriedResponse(
            tSecondRequestOptions,
          );
          when(() => mockDio.fetch<dynamic>(tFirstRequestOptions))
              .thenAnswer((_) async => tFirstRetriedResponse);
          when(() => mockDio.fetch<dynamic>(tSecondRequestOptions))
              .thenAnswer((_) async => tSecondRetriedResponse);
          final mockSecondErrorHandler = MockErrorInterceptorHandler();

          // when
          final firstOnError = interceptor.onError(
            buildDioException(tFirstRequestOptions, statusCode: 401),
            mockErrorHandler,
          );
          final secondOnError = interceptor.onError(
            buildDioException(tSecondRequestOptions, statusCode: 401),
            mockSecondErrorHandler,
          );
          tRefreshCompleter.complete(tFreshSessionModel);
          await Future.wait([firstOnError, secondOnError]);

          // then
          verify(() => mockAuthApi.refreshSession(tRefreshToken)).called(1);
          verify(() => mockSessionStorage.save(tFreshSessionModel)).called(1);
          verify(() => mockErrorHandler.resolve(tFirstRetriedResponse))
              .called(1);
          verify(() => mockSecondErrorHandler.resolve(tSecondRetriedResponse))
              .called(1);
        },
      );

      test(
        '''
        GIVEN the session storage holds a session
        AND a first request failed with a 401 and its refresh is finished
        AND a second request that was sent with the same access token
            fails with a 401 later on
        WHEN the second error passes through the interceptor
        THEN the session is refreshed again for the second request,
             because the first refresh is over and not reused''',
        () async {
          // given
          setUpMockSessionStorageSession(tSessionModel);
          setUpMockAuthApiRefreshSessionSuccess();
          setUpMockSessionStorageSaveSuccess();
          final tFirstRequestOptions = buildRequestOptions();
          final tSecondRequestOptions = buildRequestOptions();
          setUpMockDioFetchSuccess(buildRetriedResponse(tFirstRequestOptions));
          await interceptor.onError(
            buildDioException(tFirstRequestOptions, statusCode: 401),
            mockErrorHandler,
          );

          // when
          await interceptor.onError(
            buildDioException(tSecondRequestOptions, statusCode: 401),
            MockErrorInterceptorHandler(),
          );

          // then
          verify(() => mockAuthApi.refreshSession(tRefreshToken)).called(2);
        },
      );
    });
  });
}
