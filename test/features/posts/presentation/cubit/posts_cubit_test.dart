import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/create_post_use_case.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/get_posts_use_case.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_cubit.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPostsUseCase extends Mock implements GetPostsUseCase;

class MockCreatePostUseCase extends Mock implements CreatePostUseCase;

void main() {
  late MockGetPostsUseCase mockGetPosts;
  late MockCreatePostUseCase mockCreatePost;

  setUp(() {
    mockGetPosts = MockGetPostsUseCase();
    mockCreatePost = MockCreatePostUseCase();
  });

  PostsCubit buildCubit() =>
      PostsCubit(getPosts: mockGetPosts, createPost: mockCreatePost);

  const tTitle = 'New title';
  const tContent = 'New content';
  final tOlderPost = Post(
    id: '7a6b5c4d-3e2f-4a1b-9c8d-7e6f5a4b3c2d',
    title: 'Older title',
    content: 'Older content',
    createdAt: DateTime.utc(2026, 1, 1, 9, 15),
  );
  final tNewPost = Post(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: tTitle,
    content: tContent,
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );
  const tFailure = ServerFailure('offline');

  test(
    '''
    GIVEN a new posts cubit
    WHEN its state is read
    THEN loading the posts and creating a post have not started''',
    () {
      // given
      final cubit = buildCubit();
      // when
      final result = cubit.state;
      // then
      expect(result, const PostsState());
    },
  );

  group('load', () {
    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN there are posts on the server
      WHEN the posts are loaded
      THEN the posts are loading
      AND then the posts are loaded''',
      // given
      setUp: () =>
          when(() => mockGetPosts())
              .thenAnswer((_) async => Result.ok([tOlderPost])),
      build: buildCubit,
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const PostsState(posts: AsyncLoading()),
        PostsState(posts: AsyncData([tOlderPost])),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN the device is offline
      WHEN the posts are loaded
      THEN the posts are loading
      AND then loading the posts failed with the server failure from the use
          case''',
      // given
      setUp: () =>
          when(() => mockGetPosts())
              .thenAnswer((_) async => const Result.error(tFailure)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const PostsState(posts: AsyncLoading()),
        const PostsState(posts: AsyncError(tFailure)),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN the posts are already loading
      WHEN the user pulls to refresh
      THEN nothing is emitted
      AND the use case is not called a second time''',
      // given
      build: buildCubit,
      seed: () => const PostsState(posts: AsyncLoading()),
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => <PostsState>[],
      verify: (_) => verifyZeroInteractions(mockGetPosts),
    );
  });

  group('create', () {
    void setUpMockCreatePost(Result<Post> result) {
      when(
        () => mockCreatePost(
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => result);
    }

    Future<void> create(PostsCubit cubit) =>
        cubit.create(title: tTitle, content: tContent);

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN the posts are loaded
      WHEN the user creates a post with a title and a content
      THEN creating the post is loading
      AND then the post is created
      AND the new post is added to the top of the loaded posts
      AND the use case was asked to create a post with the same title and
          content''',
      // given
      setUp: () => setUpMockCreatePost(Result.ok(tNewPost)),
      build: buildCubit,
      seed: () => PostsState(posts: AsyncData([tOlderPost])),
      // when
      act: create,
      // then
      expect: () => [
        PostsState(
          posts: AsyncData([tOlderPost]),
          createPost: const AsyncLoading(),
        ),
        PostsState(
          posts: AsyncData([tNewPost, tOlderPost]),
          createPost: AsyncData(tNewPost),
        ),
      ],
      verify: (_) =>
          verify(() => mockCreatePost(title: tTitle, content: tContent))
              .called(1),
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN the posts are loaded
      AND the device is offline
      WHEN the user creates a post
      THEN creating the post is loading
      AND then creating the post failed with the server failure from the use
          case
      AND the loaded posts stay the same''',
      // given
      setUp: () => setUpMockCreatePost(const Result.error(tFailure)),
      build: buildCubit,
      seed: () => PostsState(posts: AsyncData([tOlderPost])),
      // when
      act: create,
      // then
      expect: () => [
        PostsState(
          posts: AsyncData([tOlderPost]),
          createPost: const AsyncLoading(),
        ),
        PostsState(
          posts: AsyncData([tOlderPost]),
          createPost: const AsyncError(tFailure),
        ),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN the posts have not loaded yet
      WHEN the user creates a post
      THEN nothing is emitted
      AND the create post use case is not called, because there is no list
          to add the new post to''',
      // given
      build: buildCubit,
      // when
      act: create,
      // then
      expect: () => <PostsState>[],
      verify: (_) => verifyZeroInteractions(mockCreatePost),
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN the posts are loaded
      AND a post is already being created
      WHEN the user taps create again
      THEN nothing is emitted
      AND the use case is not called a second time''',
      // given
      build: buildCubit,
      seed: () => PostsState(
        posts: AsyncData([tOlderPost]),
        createPost: const AsyncLoading(),
      ),
      // when
      act: create,
      // then
      expect: () => <PostsState>[],
      verify: (_) => verifyZeroInteractions(mockCreatePost),
    );
  });
}
