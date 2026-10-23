import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/app/domain/entities/session.dart';
import 'package:flutter_auth_template/core/app/domain/repositories/session_repository.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio;

class MockAuthApi extends Mock implements AuthApi;

class MockSessionRepository extends Mock implements SessionRepository;

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler;

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler;

void main() {
  late AuthInterceptor interceptor;
  late MockDio mockDio;
  late MockAuthApi mockAuthApi;
  late MockSessionRepository mockSessionRepository;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockErrorInterceptorHandler mockErrorHandler;
  late int sessionExpiredCount;
  Session? currentSession;

  setUpAll(() {
    final requestOptions = RequestOptions();
    registerFallbackValue(requestOptions);
    registerFallbackValue(DioException(requestOptions: requestOptions));
    registerFallbackValue(Response<dynamic>(requestOptions: requestOptions));
    registerFallbackValue(const Session(accessToken: '', refreshToken: ''));
  });

  setUp(() {
    mockDio = MockDio();
    mockAuthApi = MockAuthApi();
    mockSessionRepository = MockSessionRepository();
    mockRequestHandler = MockRequestInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
    sessionExpiredCount = 0;
    currentSession = null;
    // the mock repository keeps the session like the real one
    when(() => mockSessionRepository.session).thenAnswer((_) => currentSession);
    when(() => mockSessionRepository.save(any()))
        .thenAnswer((invocation) async {
          currentSession = invocation.positionalArguments.single as Session;
        });
    when(() => mockSessionRepository.clear()).thenAnswer((_) async {
      currentSession = null;
    });
    interceptor = AuthInterceptor(
      dio: mockDio,
      authApi: mockAuthApi,
      sessionRepository: mockSessionRepository,
      onSessionExpired: () => sessionExpiredCount++,
    );
  });

  const tAccessToken = 'test-access-token';
  const tRefreshToken = 'test-refresh-token';
  const tSession = Session(
    accessToken: tAccessToken,
    refreshToken: tRefreshToken,
  );
  const tFreshAccessToken = 'fresh-access-token';
  const tFreshRefreshToken = 'fresh-refresh-token';
  const tFreshSession = Session(
    accessToken: tFreshAccessToken,
    refreshToken: tFreshRefreshToken,
  );
  final tFreshSessionResponseModel = SessionResponseModel(
    accessToken: tFreshAccessToken,
    refreshToken: tFreshRefreshToken,
  );

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

  void setUpMockAuthApiRefreshSuccess() {
    when(() => mockAuthApi.refreshSession(any()))
        .thenAnswer((_) async => tFreshSessionResponseModel);
  }

  void setUpMockDioRetrySuccess(Response<dynamic> response) {
    when(() => mockDio.fetch<dynamic>(any())).thenAnswer((_) async => response);
  }

  group('onRequest', () {
    test(
      '''
      GIVEN the user is signed in
      AND a request that does not say anything about authentication
      WHEN the request passes through the interceptor
      THEN the access token is added to the request as a "Bearer"
           Authorization header
      AND the request is passed on''',
      () {
        // given
        currentSession = tSession;
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
      GIVEN the user is signed in
      AND a request that is marked as not requiring authentication,
          like the sign in request
      WHEN the request passes through the interceptor
      THEN no Authorization header is added to the request
      AND the request is passed on''',
      () {
        // given
        currentSession = tSession;
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
      GIVEN the user is signed out
      WHEN a request passes through the interceptor
      THEN no Authorization header is added to the request
      AND the request is passed on''',
      () {
        // given
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
    group('errors that are passed on without a refresh', () {
      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 403 that is not about the access token,
            like a row level security error
        WHEN the error passes through the interceptor
        THEN the session is not refreshed
        AND the same error is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tError = buildDioException(
            buildRequestOptions(),
            statusCode: 403,
            data: {'code': '42501'},
          );
          // when
          await interceptor.onError(tError, mockErrorHandler);
          // then
          verifyZeroInteractions(mockAuthApi);
          verify(() => mockErrorHandler.next(tError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed out
        AND a request failed with a 401 Unauthorized
        WHEN the error passes through the interceptor
        THEN the session is not refreshed, because there is nothing to refresh
        AND the same error is passed on''',
        () async {
          // given
          final tError = buildDioException(
            buildRequestOptions(sentWithAccessToken: null),
            statusCode: 401,
          );
          // when
          await interceptor.onError(tError, mockErrorHandler);
          // then
          verifyZeroInteractions(mockAuthApi);
          verify(() => mockErrorHandler.next(tError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request that does not require authentication failed with a 401,
            like a sign in with a wrong password
        WHEN the error passes through the interceptor
        THEN the session is not refreshed
        AND the same error is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tError = buildDioException(
            buildRequestOptions(
              sentWithAccessToken: null,
              extra: {requiresAuthKey: false},
            ),
            statusCode: 401,
          );
          // when
          await interceptor.onError(tError, mockErrorHandler);
          // then
          verifyZeroInteractions(mockAuthApi);
          verify(() => mockErrorHandler.next(tError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND the refresh token is still valid
        AND the server answers the request with a 401 even after a refresh
        WHEN a request fails with a 401, so the session is refreshed and the
             request is retried
        AND the 401 error of the retried request passes through the
            interceptor too
        THEN the session is refreshed only once
        AND the request is retried only once
        AND the 401 error of the retried request is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRequestOptions = buildRequestOptions();
          final tRetryError = buildDioException(
            tRequestOptions,
            statusCode: 401,
          );
          setUpMockAuthApiRefreshSuccess();
          when(() => mockDio.fetch<dynamic>(any()))
              .thenAnswer((_) async => throw tRetryError);
          // when
          await interceptor.onError(
            buildDioException(tRequestOptions, statusCode: 401),
            mockErrorHandler,
          );
          await interceptor.onError(tRetryError, mockErrorHandler);
          // then
          verify(() => mockAuthApi.refreshSession(any())).called(1);
          verify(() => mockDio.fetch<dynamic>(any())).called(1);
          verify(() => mockErrorHandler.next(tRetryError)).called(2);
        },
      );
    });

    group('expired access token', () {
      test(
        '''
        GIVEN the user is signed in
        AND a request sent with the current access token failed with a 401
        AND the refresh token is still valid
        WHEN the error passes through the interceptor
        THEN the session is refreshed with the current refresh token
        AND the fresh session is saved
        AND the request is retried once
        AND the response of the retried request is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRequestOptions = buildRequestOptions();
          final tRetriedResponse = buildRetriedResponse(tRequestOptions);
          setUpMockAuthApiRefreshSuccess();
          setUpMockDioRetrySuccess(tRetriedResponse);
          // when
          await interceptor.onError(
            buildDioException(tRequestOptions, statusCode: 401),
            mockErrorHandler,
          );
          // then
          verify(() => mockAuthApi.refreshSession(tRefreshToken)).called(1);
          verify(() => mockSessionRepository.save(tFreshSession)).called(1);
          expect(currentSession, tFreshSession);
          verify(() => mockDio.fetch<dynamic>(tRequestOptions)).called(1);
          verify(() => mockErrorHandler.resolve(tRetriedResponse)).called(1);
          verifyNever(() => mockErrorHandler.next(any()));
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 403 "bad_jwt", which is what Supabase Auth
            sends for an expired access token
        AND the refresh token is still valid
        WHEN the error passes through the interceptor
        THEN the session is refreshed
        AND the response of the retried request is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRequestOptions = buildRequestOptions();
          final tRetriedResponse = buildRetriedResponse(tRequestOptions);
          setUpMockAuthApiRefreshSuccess();
          setUpMockDioRetrySuccess(tRetriedResponse);
          // when
          await interceptor.onError(
            buildDioException(
              tRequestOptions,
              statusCode: 403,
              data: {'error_code': 'bad_jwt'},
            ),
            mockErrorHandler,
          );
          // then
          verify(() => mockAuthApi.refreshSession(tRefreshToken)).called(1);
          verify(() => mockErrorHandler.resolve(tRetriedResponse)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401 but was sent with an older access token,
            because another request already refreshed the session
        WHEN the error passes through the interceptor
        THEN the session is not refreshed again
        AND the request is retried right away
        AND the response of the retried request is passed on''',
        () async {
          // given
          currentSession = tFreshSession;
          final tRequestOptions = buildRequestOptions();
          final tRetriedResponse = buildRetriedResponse(tRequestOptions);
          setUpMockDioRetrySuccess(tRetriedResponse);
          // when
          await interceptor.onError(
            buildDioException(tRequestOptions, statusCode: 401),
            mockErrorHandler,
          );
          // then
          verifyZeroInteractions(mockAuthApi);
          verify(() => mockDio.fetch<dynamic>(tRequestOptions)).called(1);
          verify(() => mockErrorHandler.resolve(tRetriedResponse)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND two requests sent with the current access token failed with a 401
        AND the refresh token is still valid
        WHEN both errors pass through the interceptor at the same time
        THEN the session is refreshed only once
        AND both requests are retried
        AND the responses of both retried requests are passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRefreshCompleter = Completer<SessionResponseModel>();
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) => tRefreshCompleter.future);
          final tFirstOptions = buildRequestOptions();
          final tSecondOptions = buildRequestOptions();
          final tRetriedResponse = buildRetriedResponse(tFirstOptions);
          setUpMockDioRetrySuccess(tRetriedResponse);
          final tFirstHandler = MockErrorInterceptorHandler();
          final tSecondHandler = MockErrorInterceptorHandler();
          // when
          final first = interceptor.onError(
            buildDioException(tFirstOptions, statusCode: 401),
            tFirstHandler,
          );
          final second = interceptor.onError(
            buildDioException(tSecondOptions, statusCode: 401),
            tSecondHandler,
          );
          tRefreshCompleter.complete(tFreshSessionResponseModel);
          await Future.wait([first, second]);
          // then
          verify(() => mockAuthApi.refreshSession(tRefreshToken)).called(1);
          verify(() => mockDio.fetch<dynamic>(any())).called(2);
          verify(() => tFirstHandler.resolve(tRetriedResponse)).called(1);
          verify(() => tSecondHandler.resolve(tRetriedResponse)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND the refresh token is still valid
        WHEN a request fails with a 401, so the session is refreshed
        AND later a request sent with the fresh access token fails with a 401
        THEN the session is refreshed a second time, with the fresh refresh
             token, because the first refresh has already finished''',
        () async {
          // given
          currentSession = tSession;
          setUpMockAuthApiRefreshSuccess();
          setUpMockDioRetrySuccess(buildRetriedResponse(RequestOptions()));
          // when
          await interceptor.onError(
            buildDioException(buildRequestOptions(), statusCode: 401),
            mockErrorHandler,
          );
          await interceptor.onError(
            buildDioException(
              buildRequestOptions(sentWithAccessToken: tFreshAccessToken),
              statusCode: 401,
            ),
            mockErrorHandler,
          );
          // then
          verify(() => mockAuthApi.refreshSession(tRefreshToken)).called(1);
          verify(() => mockAuthApi.refreshSession(tFreshRefreshToken))
              .called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401
        AND the refresh token is still valid
        WHEN the error passes through the interceptor
        AND the user signs out while the session is being refreshed
        THEN the fresh session is not saved, so the user stays signed out
        AND the request is not retried, because there is no token to send
        AND the 401 error of the request is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRefreshCompleter = Completer<SessionResponseModel>();
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) => tRefreshCompleter.future);
          final tError = buildDioException(
            buildRequestOptions(),
            statusCode: 401,
          );
          // when
          final result = interceptor.onError(tError, mockErrorHandler);
          currentSession = null;
          tRefreshCompleter.complete(tFreshSessionResponseModel);
          await result;
          // then
          verifyNever(() => mockSessionRepository.save(any()));
          expect(currentSession, isNull);
          verifyZeroInteractions(mockDio);
          verify(() => mockErrorHandler.next(tError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401
        AND the refresh token is still valid
        AND the server is having problems with the request itself
        WHEN the error passes through the interceptor
        THEN the request is retried after the refresh
        AND the 500 error of the retried request is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRequestOptions = buildRequestOptions();
          final tRetryError = buildDioException(
            tRequestOptions,
            statusCode: 500,
          );
          setUpMockAuthApiRefreshSuccess();
          when(() => mockDio.fetch<dynamic>(any()))
              .thenAnswer((_) async => throw tRetryError);
          // when
          await interceptor.onError(
            buildDioException(tRequestOptions, statusCode: 401),
            mockErrorHandler,
          );
          // then
          verify(() => mockErrorHandler.next(tRetryError)).called(1);
          verifyNever(() => mockErrorHandler.resolve(any()));
        },
      );
    });

    group('failed refresh', () {
      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401
        AND the refresh token was revoked or has expired
        WHEN the error passes through the interceptor
        THEN the session is cleared
        AND the app is told that the session expired, so it shows sign in
        AND the request is not retried
        AND the 400 error of the refresh is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRefreshError = buildRefreshDioException(statusCode: 400);
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) async => throw tRefreshError);
          // when
          await interceptor.onError(
            buildDioException(buildRequestOptions(), statusCode: 401),
            mockErrorHandler,
          );
          // then
          verify(() => mockSessionRepository.clear()).called(1);
          expect(currentSession, isNull);
          expect(sessionExpiredCount, 1);
          verifyZeroInteractions(mockDio);
          verify(() => mockErrorHandler.next(tRefreshError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401
        AND the refresh token was revoked
        WHEN the error passes through the interceptor
        AND the user signs out and in again while the session is being
            refreshed
        THEN the new session is not cleared
        AND the app is not told that the session expired
        AND the 400 error of the refresh is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRefreshCompleter = Completer<SessionResponseModel>();
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) => tRefreshCompleter.future);
          final tRefreshError = buildRefreshDioException(statusCode: 400);
          // when
          final result = interceptor.onError(
            buildDioException(buildRequestOptions(), statusCode: 401),
            mockErrorHandler,
          );
          currentSession = tFreshSession;
          tRefreshCompleter.completeError(tRefreshError);
          await result;
          // then
          verifyNever(() => mockSessionRepository.clear());
          expect(currentSession, tFreshSession);
          expect(sessionExpiredCount, 0);
          verify(() => mockErrorHandler.next(tRefreshError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401
        AND the device went offline
        WHEN the error passes through the interceptor
        THEN the session is kept, so the user stays signed in
        AND the app is not told that the session expired
        AND the connection error of the refresh is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRefreshError = buildRefreshDioException();
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) async => throw tRefreshError);
          // when
          await interceptor.onError(
            buildDioException(buildRequestOptions(), statusCode: 401),
            mockErrorHandler,
          );
          // then
          verifyNever(() => mockSessionRepository.clear());
          expect(sessionExpiredCount, 0);
          verify(() => mockErrorHandler.next(tRefreshError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401
        AND the app has refreshed too often, so refreshes are rate limited
        WHEN the error passes through the interceptor
        THEN the session is kept, so the user stays signed in
        AND the app is not told that the session expired
        AND the 429 Too Many Requests error of the refresh is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRefreshError = buildRefreshDioException(statusCode: 429);
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) async => throw tRefreshError);
          // when
          await interceptor.onError(
            buildDioException(buildRequestOptions(), statusCode: 401),
            mockErrorHandler,
          );
          // then
          verifyNever(() => mockSessionRepository.clear());
          expect(sessionExpiredCount, 0);
          verify(() => mockErrorHandler.next(tRefreshError)).called(1);
        },
      );

      test(
        '''
        GIVEN the user is signed in
        AND a request failed with a 401
        AND the auth server is having problems
        WHEN the error passes through the interceptor
        THEN the session is kept, so the user stays signed in
        AND the 500 Internal Server Error of the refresh is passed on''',
        () async {
          // given
          currentSession = tSession;
          final tRefreshError = buildRefreshDioException(statusCode: 500);
          when(() => mockAuthApi.refreshSession(any()))
              .thenAnswer((_) async => throw tRefreshError);
          // when
          await interceptor.onError(
            buildDioException(buildRequestOptions(), statusCode: 401),
            mockErrorHandler,
          );
          // then
          verifyNever(() => mockSessionRepository.clear());
          expect(sessionExpiredCount, 0);
          verify(() => mockErrorHandler.next(tRefreshError)).called(1);
        },
      );
    });
  });
}
