import 'package:dio/dio.dart';
import 'package:flutter_auth_template/features/profile/data/datasources/profile_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  const tBaseUrl = 'https://test-project.supabase.co';

  late ProfileApi profileApi;
  late MockHttpClientAdapter mockHttpClientAdapter;

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

  const tIdFilter = 'eq.5f1c2a34-9d1e-4b7a-8c55-0a1b2c3d4e5f';

  group('getProfile', () {
    test(
      '''
      GIVEN the server answers with the JSON of a single profile
      WHEN getProfile is called with an id filter
      THEN a GET request is sent to /rest/v1/profiles
      AND the id filter is sent as the "id" query parameter
      AND the Accept header asks for a single JSON object instead of a list
      AND the response is parsed into a ProfileResponseModel''',
      () async {
        // given
        when(() => mockHttpClientAdapter.fetch(any(), any(), any())).thenAnswer(
          (_) async => ResponseBody.fromString(
            fixture('profile.json'),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        );

        // when
        final result = await profileApi.getProfile(tIdFilter);

        // then
        final request =
            verify(
                  () => mockHttpClientAdapter.fetch(captureAny(), any(), any()),
                ).captured.single
                as RequestOptions;
        expect(request.method, 'GET');
        expect(
          request.uri.toString(),
          '$tBaseUrl/rest/v1/profiles?id=$tIdFilter',
        );
        expect(request.headers['Accept'], 'application/vnd.pgrst.object+json');
        expect(result.name, 'Test User');
        expect(result.createdAt, DateTime.utc(2026, 1, 1, 10));
      },
    );
  });
}
