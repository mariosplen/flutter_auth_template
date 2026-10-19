import 'package:dio/dio.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter;

void main() {
  late ProfileApi profileApi;
  late MockHttpClientAdapter mockHttpClientAdapter;

  const tBaseUrl = 'https://test-project.supabase.co';
  const tUserId = '5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';

  setUpAll(() {
    registerFallbackValue(RequestOptions());
  });

  setUp(() {
    mockHttpClientAdapter = MockHttpClientAdapter();
    profileApi = ProfileApi(
      Dio(BaseOptions(baseUrl: tBaseUrl))
        ..httpClientAdapter = mockHttpClientAdapter,
    );
  });

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

  RequestOptions verifySingleRequest() =>
      verify(() => mockHttpClientAdapter.fetch(captureAny(), any(), any()))
              .captured
              .single
          as RequestOptions;

  group('getUser', () {
    test(
      '''
      GIVEN a signed in user
      WHEN getUser is called
      THEN a GET request is sent to /auth/v1/user
      AND the user in the response is parsed into a user model with the id and
          the email''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(fixture('user.json'));
        // when
        final result = await profileApi.getUser();
        // then
        final request = verifySingleRequest();
        expect(request.method, 'GET');
        expect(request.uri.toString(), '$tBaseUrl/auth/v1/user');
        expect(result.id, tUserId);
        expect(result.email, 'test@example.com');
      },
    );
  });

  group('getProfile', () {
    test(
      '''
      GIVEN the user has a profile row
      WHEN getProfile is called with an "eq." filter on the user id
      THEN a GET request is sent to /rest/v1/profiles with that filter
      AND it asks PostgREST for a single object instead of a list
      AND the profile row in the response is parsed into a profile model''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(fixture('profile.json'));
        // when
        final result = await profileApi.getProfile('eq.$tUserId');
        // then
        final request = verifySingleRequest();
        expect(request.method, 'GET');
        expect(request.uri.path, '/rest/v1/profiles');
        expect(request.queryParameters, {'id': 'eq.$tUserId'});
        expect(request.headers['Accept'], 'application/vnd.pgrst.object+json');
        expect(result.id, tUserId);
        expect(result.name, 'Test User');
      },
    );
  });
}
