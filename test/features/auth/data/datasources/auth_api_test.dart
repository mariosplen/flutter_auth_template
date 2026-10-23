import 'package:dio/dio.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/models/session_response_model.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter;

void main() {
  late AuthApi authApi;
  late MockHttpClientAdapter mockHttpClientAdapter;

  const tBaseUrl = 'https://test-project.supabase.co';

  setUpAll(() {
    registerFallbackValue(RequestOptions());
  });

  setUp(() {
    mockHttpClientAdapter = MockHttpClientAdapter();
    authApi = AuthApi(
      Dio(BaseOptions(baseUrl: tBaseUrl))
        ..httpClientAdapter = mockHttpClientAdapter,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';
  const tName = 'Test User';
  const tRefreshToken = 'test-refresh-token';

  void setUpMockHttpClientAdapterSuccess200(String body) {
    when(() => mockHttpClientAdapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => ResponseBody.fromString(
        body,
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  void setUpMockHttpClientAdapterSuccess204() {
    when(() => mockHttpClientAdapter.fetch(any(), any(), any()))
        .thenAnswer((_) async => ResponseBody.fromString('', 204));
  }

  RequestOptions verifySingleRequest() =>
      verify(() => mockHttpClientAdapter.fetch(captureAny(), any(), any()))
              .captured
              .single
          as RequestOptions;

  group('signUp', () {
    test(
      '''
      GIVEN email confirmation is turned off in Supabase
      WHEN signUp is called with an email, a password and the user metadata
      THEN a POST request is sent to /auth/v1/signup
      AND its body has the email, the password and the metadata under "data"
      AND the request is marked as not requiring authentication
      AND the session in the response is parsed into a signed up response''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(fixture('session.json'));
        // when
        final result = await authApi.signUp(tEmail, tPassword, {'name': tName});
        // then
        final request = verifySingleRequest();
        expect(request.method, 'POST');
        expect(request.uri.toString(), '$tBaseUrl/auth/v1/signup');
        expect(request.data, {
          'email': tEmail,
          'password': tPassword,
          'data': {'name': tName},
        });
        expect(request.extra[requiresAuthKey], isFalse);
        expect(
          result,
          isA<SignedUpWithSession>().having(
            (signedUp) => signedUp.session.accessToken,
            'session.accessToken',
            'test-access-token',
          ),
        );
      },
    );
  });

  group('signIn', () {
    test(
      '''
      GIVEN an account with this email and password
      WHEN signIn is called with the email and the password
      THEN a POST request is sent to /auth/v1/token with the password grant
      AND its body has the email and the password
      AND the request is marked as not requiring authentication
      AND the session in the response is parsed into a session response model''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(fixture('session.json'));
        // when
        final result = await authApi.signIn(tEmail, tPassword);
        // then
        final request = verifySingleRequest();
        expect(request.method, 'POST');
        expect(
          request.uri.toString(),
          '$tBaseUrl/auth/v1/token?grant_type=password',
        );
        expect(request.data, {'email': tEmail, 'password': tPassword});
        expect(request.extra[requiresAuthKey], isFalse);
        expect(
          result,
          isA<SessionResponseModel>()
              .having((s) => s.accessToken, 'accessToken', 'test-access-token')
              .having((s) => s.refreshToken, 'refreshToken', tRefreshToken),
        );
      },
    );
  });

  group('refreshSession', () {
    test(
      '''
      GIVEN a refresh token that is still valid
      WHEN refreshSession is called with the refresh token
      THEN a POST request is sent to /auth/v1/token with the refresh token
           grant
      AND its body has the refresh token under "refresh_token"
      AND the request is marked as not requiring authentication
      AND the new session in the response is parsed into a session response model''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(fixture('session.json'));
        // when
        final result = await authApi.refreshSession(tRefreshToken);
        // then
        final request = verifySingleRequest();
        expect(request.method, 'POST');
        expect(
          request.uri.toString(),
          '$tBaseUrl/auth/v1/token?grant_type=refresh_token',
        );
        expect(request.data, {'refresh_token': tRefreshToken});
        expect(request.extra[requiresAuthKey], isFalse);
        expect(result.accessToken, 'test-access-token');
      },
    );
  });

  group('signOut', () {
    test(
      '''
      GIVEN a signed in user
      WHEN signOut is called
      THEN a POST request is sent to /auth/v1/logout for this device only
      AND the request is not marked as not requiring authentication, so the
          access token is sent with it''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess204();
        // when
        await authApi.signOut();
        // then
        final request = verifySingleRequest();
        expect(request.method, 'POST');
        expect(request.uri.toString(), '$tBaseUrl/auth/v1/logout?scope=local');
        expect(request.extra[requiresAuthKey], isNull);
      },
    );
  });
}
