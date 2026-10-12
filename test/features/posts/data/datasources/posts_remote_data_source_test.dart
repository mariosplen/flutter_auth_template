import 'package:dio/dio.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_api.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsApi extends Mock implements PostsApi {}

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
  final tDioException = DioException(
    requestOptions: RequestOptions(path: '/rest/v1/posts'),
    type: .connectionError,
  );

  group('getPosts', () {
    test(
      '''
      GIVEN the API answers with a list of posts
      WHEN getPosts is called
      THEN the API is asked for the posts exactly once
      AND the list of the API is returned''',
      () async {
        // given
        final tPostResponseModels = [tPostResponseModel];
        when(() => mockPostsApi.getPosts())
            .thenAnswer((_) async => tPostResponseModels);

        // when
        final result = await dataSource.getPosts();

        // then
        expect(result, same(tPostResponseModels));
        verify(() => mockPostsApi.getPosts()).called(1);
        verifyNoMoreInteractions(mockPostsApi);
      },
    );

    test(
      '''
      GIVEN the API fails with a DioException
      WHEN getPosts is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        when(() => mockPostsApi.getPosts()).thenThrow(tDioException);

        // when
        final call = dataSource.getPosts;

        // then
        await expectLater(call, throwsA(ServerFailure(tDioException)));
      },
    );
  });

  group('createPost', () {
    test(
      '''
      GIVEN the API creates the post and answers with it
      WHEN createPost is called with a title and a content
      THEN the API is asked to create a post with that title and that content
      AND the post of the API is returned''',
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
      GIVEN the API fails with a DioException
      WHEN createPost is called
      THEN a ServerFailure is thrown
      AND the failure carries the DioException of the API as its cause''',
      () async {
        // given
        when(() => mockPostsApi.createPost(any(), any()))
            .thenThrow(tDioException);

        // when
        final call = dataSource.createPost;

        // then
        await expectLater(
          () => call(title: tTitle, content: tContent),
          throwsA(ServerFailure(tDioException)),
        );
      },
    );
  });
}
