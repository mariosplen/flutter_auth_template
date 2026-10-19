import 'package:dio/dio.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter;

void main() {
  late PostsApi postsApi;
  late MockHttpClientAdapter mockHttpClientAdapter;

  const tBaseUrl = 'https://test-project.supabase.co';

  setUpAll(() {
    registerFallbackValue(RequestOptions());
  });

  setUp(() {
    mockHttpClientAdapter = MockHttpClientAdapter();
    postsApi = PostsApi(
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

  group('getPosts', () {
    test(
      '''
      GIVEN there are two posts on the server
      WHEN getPosts is called
      THEN a GET request is sent to /rest/v1/posts for all columns, with the
           newest posts first
      AND the two posts in the response are parsed into post models, in the
          same order''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(fixture('posts.json'));
        // when
        final result = await postsApi.getPosts();
        // then
        final request = verifySingleRequest();
        expect(request.method, 'GET');
        expect(
          request.uri.toString(),
          '$tBaseUrl/rest/v1/posts?select=*&order=created_at.desc',
        );
        expect(result.map((post) => post.title), ['Test title', 'Older title']);
      },
    );
  });

  group('createPost', () {
    const tTitle = 'Test title';
    const tContent = 'Test content';

    test(
      '''
      GIVEN a signed in user
      WHEN createPost is called with a title and a content
      THEN a POST request is sent to /rest/v1/posts for all columns
      AND its body has the title and the content
      AND it asks PostgREST to return the created post as a single object
      AND the created post in the response is parsed into a post model''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess200(fixture('post.json'));
        // when
        final result = await postsApi.createPost(tTitle, tContent);
        // then
        final request = verifySingleRequest();
        expect(request.method, 'POST');
        expect(request.uri.toString(), '$tBaseUrl/rest/v1/posts?select=*');
        expect(request.data, {'title': tTitle, 'content': tContent});
        expect(request.headers['Prefer'], 'return=representation');
        expect(request.headers['Accept'], 'application/vnd.pgrst.object+json');
        expect(result.id, '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c');
        expect(result.title, tTitle);
        expect(result.content, tContent);
      },
    );
  });
}
