import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_auth_template/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource;

void main() {
  late PostsRepositoryImpl repository;
  late MockPostsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPostsRemoteDataSource();
    repository = PostsRepositoryImpl(mockRemoteDataSource);
  });

  const tTitle = 'Test title';
  const tContent = 'Test content';
  final tCreatedAt = DateTime.utc(2026, 1, 2, 12, 30);
  final tPostResponseModel = PostResponseModel(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: tTitle,
    content: tContent,
    createdAt: tCreatedAt,
  );
  final tPost = Post(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: tTitle,
    content: tContent,
    createdAt: tCreatedAt,
  );
  const tFailure = ServerFailure('offline');

  group('getPosts', () {
    test(
      '''
      GIVEN there are posts on the server
      WHEN the posts are fetched
      THEN an Ok result with the posts as entities is returned''',
      () async {
        // given
        when(() => mockRemoteDataSource.getPosts())
            .thenAnswer((_) async => [tPostResponseModel]);
        // when
        final result = await repository.getPosts();
        // then
        verify(() => mockRemoteDataSource.getPosts()).called(1);
        expect(
          result,
          isA<Ok<List<Post>>>().having((ok) => ok.value, 'value', [tPost]),
        );
      },
    );

    test(
      '''
      GIVEN the device is offline
      WHEN the posts are fetched
      THEN an Err result with the server failure from the remote data source
           is returned''',
      () async {
        // given
        when(() => mockRemoteDataSource.getPosts()).thenThrow(tFailure);
        // when
        final result = await repository.getPosts();
        // then
        expect(
          result,
          isA<Err<List<Post>>>().having((e) => e.failure, 'failure', tFailure),
        );
      },
    );

    test(
      '''
      GIVEN the posts table has a shape the app does not expect
      WHEN the posts are fetched
      THEN an Err result with a generic failure is returned
      AND the generic failure has the parsing error as its cause''',
      () async {
        // given
        const tError = FormatException('unexpected post');
        when(() => mockRemoteDataSource.getPosts()).thenThrow(tError);
        // when
        final result = await repository.getPosts();
        // then
        expect(
          result,
          isA<Err<List<Post>>>().having(
            (e) => e.failure,
            'failure',
            const GenericFailure(tError),
          ),
        );
      },
    );
  });

  group('createPost', () {
    void setUpMockRemoteDataSourceCreatePost(
      Future<PostResponseModel> Function() call,
    ) {
      when(
        () => mockRemoteDataSource.createPost(
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) => call());
    }

    test(
      '''
      GIVEN a signed in user
      WHEN a post is created with a title and a content
      THEN the remote data source was asked to create a post with the same
           title and content
      AND an Ok result with the created post as an entity is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceCreatePost(() async => tPostResponseModel);
        // when
        final result = await repository.createPost(
          title: tTitle,
          content: tContent,
        );
        // then
        verify(
          () =>
              mockRemoteDataSource.createPost(title: tTitle, content: tContent),
        ).called(1);
        expect(
          result,
          isA<Ok<Post>>().having((ok) => ok.value, 'value', tPost),
        );
      },
    );

    test(
      '''
      GIVEN the device is offline
      WHEN a post is created
      THEN an Err result with the server failure from the remote data source
           is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceCreatePost(() async => throw tFailure);
        // when
        final result = await repository.createPost(
          title: tTitle,
          content: tContent,
        );
        // then
        expect(
          result,
          isA<Err<Post>>().having((e) => e.failure, 'failure', tFailure),
        );
      },
    );

    test(
      '''
      GIVEN the posts table has a shape the app does not expect
      WHEN a post is created
      THEN an Err result with a generic failure is returned''',
      () async {
        // given
        const tError = FormatException('unexpected post');
        setUpMockRemoteDataSourceCreatePost(() async => throw tError);
        // when
        final result = await repository.createPost(
          title: tTitle,
          content: tContent,
        );
        // then
        expect(
          result,
          isA<Err<Post>>().having(
            (e) => e.failure,
            'failure',
            const GenericFailure(tError),
          ),
        );
      },
    );
  });
}
