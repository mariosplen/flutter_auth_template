import 'package:dio/dio.dart';
import 'package:flutter_auth_template/features/auth/data/datasources/auth_api.dart';
import 'package:flutter_auth_template/features/auth/data/models/sign_up_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  const tBaseUrl = 'https://test-project.supabase.co';

  late AuthApi authApi;
  late MockHttpClientAdapter mockHttpClientAdapter;

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
      GIVEN the server answers the sign up with a session
      WHEN signUp is called with an email, a password and the user metadata
      THEN a POST request is sent to /auth/v1/signup
      AND its body has the email, the password and the metadata under "data"
      AND the request is marked as not requiring authentication
      AND the response is parsed into a SignedUpWithSession''',
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

    test(
      '''
      GIVEN the server answers the sign up with only the user,
            because the email has to be confirmed first
      WHEN signUp is called
      THEN the response is parsed into a SignUpNeedsConfirmation''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(
          fixture('sign_up_needs_confirmation.json'),
        );

        // when
        final result = await authApi.signUp(tEmail, tPassword, {'name': tName});

        // then
        expect(result, isA<SignUpNeedsConfirmation>());
      },
    );
  });

  group('signIn', () {
    test(
      '''
      GIVEN the server answers the sign in with a session
      WHEN signIn is called with an email and a password
      THEN a POST request is sent to /auth/v1/token
           with the "password" grant type
      AND its body has the email and the password
      AND the request is marked as not requiring authentication
      AND the response is parsed into a SessionModel''',
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
        expect(result.accessToken, 'test-access-token');
        expect(result.refreshToken, 'test-refresh-token');
        expect(result.user.email, tEmail);
      },
    );
  });

  group('refreshSession', () {
    test(
      '''
      GIVEN the server answers the refresh with a session
      WHEN refreshSession is called with a refresh token
      THEN a POST request is sent to /auth/v1/token
           with the "refresh_token" grant type
      AND its body has the refresh token under the "refresh_token" key
      AND the request is marked as not requiring authentication,
          so that an expired access token is not sent along with it
      AND the response is parsed into a SessionModel''',
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
        expect(result.refreshToken, 'test-refresh-token');
      },
    );
  });

  group('signOut', () {
    test(
      '''
      GIVEN the server answers the sign out with an empty 204
      WHEN signOut is called
      THEN a POST request is sent to /auth/v1/logout with the "local" scope,
           so that only this device is signed out
      AND the request is not marked as not requiring authentication,
          so that the access token is sent along with it''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess204();

        // when
        await authApi.signOut();

        // then
        final request = verifySingleRequest();
        expect(request.method, 'POST');
        expect(request.uri.toString(), '$tBaseUrl/auth/v1/logout?scope=local');
        expect(request.extra.containsKey(requiresAuthKey), isFalse);
      },
    );
  });
}
