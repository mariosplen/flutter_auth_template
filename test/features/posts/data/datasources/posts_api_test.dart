import 'package:dio/dio.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  const tBaseUrl = 'https://test-project.supabase.co';

  late PostsApi postsApi;
  late MockHttpClientAdapter mockHttpClientAdapter;

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

  const tTitle = 'Test title';
  const tContent = 'Test content';

  void setUpMockHttpClientAdapterSuccess(String body, int statusCode) {
    when(() => mockHttpClientAdapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => ResponseBody.fromString(
        body,
        statusCode,
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
      GIVEN the server answers with a JSON list of two posts
      WHEN getPosts is called
      THEN a GET request is sent to /rest/v1/posts
      AND it asks for every column, ordered by the newest creation date first
      AND the response is parsed into two PostResponseModels,
          in the order in which the server sent them''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess(fixture('posts.json'), 200);

        // when
        final result = await postsApi.getPosts();

        // then
        final request = verifySingleRequest();
        expect(request.method, 'GET');
        expect(
          request.uri.toString(),
          '$tBaseUrl/rest/v1/posts?select=*&order=created_at.desc',
        );
        expect(result, hasLength(2));
        expect(result.first.title, 'Test title');
        expect(result.first.createdAt, DateTime.utc(2026, 1, 2, 12, 30));
        expect(result.last.title, 'Older title');
        expect(result.last.createdAt, DateTime.utc(2026, 1, 1, 9, 15));
      },
    );

    test(
      '''
      GIVEN the server answers with an empty JSON list
      WHEN getPosts is called
      THEN the response is parsed into an empty list''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess('[]', 200);

        // when
        final result = await postsApi.getPosts();

        // then
        expect(result, isEmpty);
      },
    );
  });

  group('createPost', () {
    test(
      '''
      GIVEN the server creates the post and answers with its JSON
      WHEN createPost is called with a title and a content
      THEN a POST request is sent to /rest/v1/posts, asking for every column
      AND its body has the title and the content
      AND the Prefer header asks the server to return the created post
      AND the Accept header asks for a single JSON object instead of a list
      AND the response is parsed into a PostResponseModel''',
      () async {
        // given
        setUpMockHttpClientAdapterSuccess(fixture('post.json'), 201);

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
