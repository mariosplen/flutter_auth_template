import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_api.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsApi extends Mock implements PostsApi;

void main() {
  late PostsRemoteDataSource dataSource;
  late MockPostsApi mockPostsApi;

  setUp(() {
    mockPostsApi = MockPostsApi();
    dataSource = PostsRemoteDataSource(mockPostsApi);
  });

  const tTitle = 'Test title';
  const tContent = 'Test content';
  final tPostResponseModel = PostResponseModel(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: tTitle,
    content: tContent,
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );
  final tConnectionError = DioException(
    requestOptions: RequestOptions(path: '/rest/v1/posts'),
    type: .connectionError,
  );
  final tServerError = DioException(
    requestOptions: RequestOptions(path: '/rest/v1/posts'),
    type: .badResponse,
  );

  group('getPosts', () {
    test(
      '''
      GIVEN there are posts on the server
      WHEN the posts are fetched
      THEN the post models from the API are returned''',
      () async {
        // given
        final tPosts = [tPostResponseModel];
        when(() => mockPostsApi.getPosts()).thenAnswer((_) async => tPosts);
        // when
        final result = await dataSource.getPosts();
        // then
        expect(result, same(tPosts));
        verify(() => mockPostsApi.getPosts()).called(1);
        verifyNoMoreInteractions(mockPostsApi);
      },
    );

    test(
      '''
      GIVEN the device is offline
      WHEN the posts are fetched
      THEN the connection error from the API is thrown as a network failure
      AND its cause is the DioException from the API''',
      () async {
        // given
        when(() => mockPostsApi.getPosts()).thenThrow(tConnectionError);
        // when
        final result = dataSource.getPosts();
        // then
        await expectLater(result, throwsA(NetworkFailure(tConnectionError)));
      },
    );
  });

  group('createPost', () {
    test(
      '''
      GIVEN a signed in user
      WHEN a post is created with a title and a content
      THEN the created post model from the API is returned
      AND the API was asked to create a post with the same title and content''',
      () async {
        // given
        when(() => mockPostsApi.createPost(any(), any()))
            .thenAnswer((_) async => tPostResponseModel);
        // when
        final result = await dataSource.createPost(
          title: tTitle,
          content: tContent,
        );
        // then
        expect(result, same(tPostResponseModel));
        verify(() => mockPostsApi.createPost(tTitle, tContent)).called(1);
        verifyNoMoreInteractions(mockPostsApi);
      },
    );

    test(
      '''
      GIVEN row level security does not allow the user to create the post
      WHEN a post is created
      THEN the error from the API is thrown as a server failure
      AND its cause is the DioException from the API''',
      () async {
        // given
        when(() => mockPostsApi.createPost(any(), any()))
            .thenThrow(tServerError);
        // when
        final result = dataSource.createPost(title: tTitle, content: tContent);
        // then
        await expectLater(result, throwsA(ServerFailure(tServerError)));
      },
    );
  });
}
