import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/data/datasources/posts_remote_data_source.dart';
import 'package:flutter_auth_template/features/posts/data/models/post_response_model.dart';
import 'package:flutter_auth_template/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource {}

void main() {
  late PostsRepositoryImpl repository;
  late MockPostsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockPostsRemoteDataSource();
    repository = PostsRepositoryImpl(mockRemoteDataSource);
  });

  const tTitle = 'Test title';
  const tContent = 'Test content';
  final tPostResponseModel = PostResponseModel(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: tTitle,
    content: tContent,
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );
  final tOlderPostResponseModel = PostResponseModel(
    id: '7a6b5c4d-3e2f-4a1b-9c8d-7e6f5a4b3c2d',
    title: 'Older title',
    content: 'Older content',
    createdAt: DateTime.utc(2026, 1, 1, 9, 15),
  );
  final tPost = Post(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: tTitle,
    content: tContent,
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );
  final tOlderPost = Post(
    id: '7a6b5c4d-3e2f-4a1b-9c8d-7e6f5a4b3c2d',
    title: 'Older title',
    content: 'Older content',
    createdAt: DateTime.utc(2026, 1, 1, 9, 15),
  );
  final tServerFailure = ServerFailure(Exception('connection refused'));
  final tUnexpectedError = StateError('the response could not be parsed');

  group('getPosts', () {
    test(
      '''
      GIVEN the remote data source returns two post models
      WHEN getPosts is called
      THEN the remote data source is asked for the posts exactly once
      AND an Ok with the two models mapped to Post entities is returned,
          in the same order''',
      () async {
        // given
        when(() => mockRemoteDataSource.getPosts()).thenAnswer(
          (_) async => [tPostResponseModel, tOlderPostResponseModel],
        );

        // when
        final result = await repository.getPosts();

        // then
        expect(
          result,
          isA<Ok<List<Post>>>().having((ok) => ok.value, 'value', [
            tPost,
            tOlderPost,
          ]),
        );
        verify(() => mockRemoteDataSource.getPosts()).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      '''
      GIVEN the remote data source returns no post models at all
      WHEN getPosts is called
      THEN an Ok with an empty list is returned''',
      () async {
        // given
        when(() => mockRemoteDataSource.getPosts()).thenAnswer((_) async => []);

        // when
        final result = await repository.getPosts();

        // then
        expect(
          result,
          isA<Ok<List<Post>>>().having((ok) => ok.value, 'value', isEmpty),
        );
      },
    );

    test(
      '''
      GIVEN the remote data source throws a Failure
      WHEN getPosts is called
      THEN an Error with that very Failure is returned''',
      () async {
        // given
        when(() => mockRemoteDataSource.getPosts()).thenThrow(tServerFailure);

        // when
        final result = await repository.getPosts();

        // then
        expect(
          result,
          isA<Error<List<Post>>>().having(
            (error) => error.failure,
            'failure',
            same(tServerFailure),
          ),
        );
      },
    );

    test(
      '''
      GIVEN the remote data source throws something that is not a Failure,
            like a response that could not be parsed
      WHEN getPosts is called
      THEN an Error with a GenericFailure is returned
      AND the GenericFailure carries what was thrown as its cause''',
      () async {
        // given
        when(() => mockRemoteDataSource.getPosts()).thenThrow(tUnexpectedError);

        // when
        final result = await repository.getPosts();

        // then
        expect(
          result,
          isA<Error<List<Post>>>().having(
            (error) => error.failure,
            'failure',
            GenericFailure(tUnexpectedError),
          ),
        );
      },
    );
  });

  group('createPost', () {
    void setUpMockRemoteDataSourceCreatePostThrows(Object error) {
      when(
        () => mockRemoteDataSource.createPost(
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      ).thenThrow(error);
    }

    test(
      '''
      GIVEN the remote data source creates the post and returns its model
      WHEN createPost is called with a title and a content
      THEN the remote data source is asked with that title and that content
      AND an Ok with the model mapped to a Post entity is returned''',
      () async {
        // given
        when(
          () => mockRemoteDataSource.createPost(
            title: any(named: 'title'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => tPostResponseModel);

        // when
        final result = await repository.createPost(
          title: tTitle,
          content: tContent,
        );

        // then
        expect(
          result,
          isA<Ok<Post>>().having((ok) => ok.value, 'value', tPost),
        );
        verify(
          () =>
              mockRemoteDataSource.createPost(title: tTitle, content: tContent),
        ).called(1);
        verifyNoMoreInteractions(mockRemoteDataSource);
      },
    );

    test(
      '''
      GIVEN the remote data source throws a Failure
      WHEN createPost is called
      THEN an Error with that very Failure is returned''',
      () async {
        // given
        setUpMockRemoteDataSourceCreatePostThrows(tServerFailure);

        // when
        final result = await repository.createPost(
          title: tTitle,
          content: tContent,
        );

        // then
        expect(
          result,
          isA<Error<Post>>().having(
            (error) => error.failure,
            'failure',
            same(tServerFailure),
          ),
        );
      },
    );

    test(
      '''
      GIVEN the remote data source throws something that is not a Failure,
            like a response that could not be parsed
      WHEN createPost is called
      THEN an Error with a GenericFailure is returned
      AND the GenericFailure carries what was thrown as its cause''',
      () async {
        // given
        setUpMockRemoteDataSourceCreatePostThrows(tUnexpectedError);

        // when
        final result = await repository.createPost(
          title: tTitle,
          content: tContent,
        );

        // then
        expect(
          result,
          isA<Error<Post>>().having(
            (error) => error.failure,
            'failure',
            GenericFailure(tUnexpectedError),
          ),
        );
      },
    );
  });
}
