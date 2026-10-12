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

class MockGetPostsUseCase extends Mock implements GetPostsUseCase {}

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

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
  final tPost = Post(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: 'Test title',
    content: 'Test content',
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );
  final tOlderPost = Post(
    id: '7a6b5c4d-3e2f-4a1b-9c8d-7e6f5a4b3c2d',
    title: 'Older title',
    content: 'Older content',
    createdAt: DateTime.utc(2026, 1, 1, 9, 15),
  );
  final tNewPost = Post(
    id: '3d2c1b0a-9f8e-4d7c-b6a5-4f3e2d1c0b9a',
    title: tTitle,
    content: tContent,
    createdAt: DateTime.utc(2026, 1, 3, 8),
  );
  final tFailure = ServerFailure(Exception('connection refused'));

  void setUpMockGetPosts(Result<List<Post>> result) {
    when(() => mockGetPosts()).thenAnswer((_) async => result);
  }

  void setUpMockCreatePost(Result<Post> result) {
    when(
      () => mockCreatePost(
        title: any(named: 'title'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async => result);
  }

  void verifyCreatePostWasNeverCalled() {
    verifyNever(
      () => mockCreatePost(
        title: any(named: 'title'),
        content: any(named: 'content'),
      ),
    );
  }

  group('initial state', () {
    test(
      '''
      GIVEN nothing was requested yet
      WHEN the cubit is created
      THEN its posts and its post creation are both initial
      AND no use case is called before somebody asks for it''',
      () {
        // when
        final cubit = buildCubit();

        // then
        expect(cubit.state, const PostsState());
        verifyZeroInteractions(mockGetPosts);
        verifyZeroInteractions(mockCreatePost);
      },
    );
  });

  group('load', () {
    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit that has not loaded anything yet
      AND the get posts use case answers with two posts
      WHEN load is called
      THEN it emits a state whose posts are loading
      AND then a state whose posts hold the two posts
      AND the use case is called once''',
      // given
      setUp: () => setUpMockGetPosts(Result.ok([tPost, tOlderPost])),
      build: buildCubit,
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const PostsState(posts: AsyncLoading()),
        PostsState(posts: AsyncData([tPost, tOlderPost])),
      ],
      verify: (_) {
        verify(() => mockGetPosts()).called(1);
      },
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit that has not loaded anything yet
      AND the get posts use case answers with a failure
      WHEN load is called
      THEN it emits a state whose posts are loading
      AND then a state whose posts hold the failure''',
      // given
      setUp: () => setUpMockGetPosts(Result.error(tFailure)),
      build: buildCubit,
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const PostsState(posts: AsyncLoading()),
        PostsState(posts: AsyncError(tFailure)),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose last load failed
      AND the get posts use case answers with a post this time
      WHEN load is called again, as when "try again" is pressed
      THEN it emits a state whose posts are loading instead of failed
      AND then a state whose posts hold the post''',
      // given
      setUp: () => setUpMockGetPosts(Result.ok([tPost])),
      build: buildCubit,
      seed: () => PostsState(posts: AsyncError(tFailure)),
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const PostsState(posts: AsyncLoading()),
        PostsState(posts: AsyncData([tPost])),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts are already loaded
      AND the get posts use case answers with a newer list of posts
      WHEN load is called again, as when the list is pulled to refresh
      THEN it emits a state whose posts are loading
      AND then a state whose posts hold the newer list''',
      // given
      setUp: () => setUpMockGetPosts(Result.ok([tNewPost, tPost])),
      build: buildCubit,
      seed: () => PostsState(posts: AsyncData([tPost])),
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => [
        const PostsState(posts: AsyncLoading()),
        PostsState(posts: AsyncData([tNewPost, tPost])),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts are already loading
      WHEN load is called a second time
      THEN it emits nothing
      AND the get posts use case is never called''',
      // given
      build: buildCubit,
      seed: () => const PostsState(posts: AsyncLoading()),
      // when
      act: (cubit) => cubit.load(),
      // then
      expect: () => const <PostsState>[],
      verify: (_) {
        verifyNever(() => mockGetPosts());
      },
    );
  });

  group('create', () {
    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts are loaded
      AND the create post use case answers with the new post
      WHEN create is called with a title and a content
      THEN it emits a state whose post creation is loading
           while the loaded posts stay as they are
      AND then a state whose post creation holds the new post
      AND in that state the new post is first in the list, before the others
      AND the use case is called once with that title and that content''',
      // given
      setUp: () => setUpMockCreatePost(Result.ok(tNewPost)),
      build: buildCubit,
      seed: () => PostsState(posts: AsyncData([tPost, tOlderPost])),
      // when
      act: (cubit) => cubit.create(title: tTitle, content: tContent),
      // then
      expect: () => [
        PostsState(
          posts: AsyncData([tPost, tOlderPost]),
          createPost: const AsyncLoading(),
        ),
        PostsState(
          posts: AsyncData([tNewPost, tPost, tOlderPost]),
          createPost: AsyncData(tNewPost),
        ),
      ],
      verify: (_) {
        verify(() => mockCreatePost(title: tTitle, content: tContent))
            .called(1);
      },
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts are loaded
      AND the create post use case answers with a failure
      WHEN create is called with a title and a content
      THEN it emits a state whose post creation is loading
      AND then a state whose post creation holds the failure
      AND in that state the loaded posts are still untouched''',
      // given
      setUp: () => setUpMockCreatePost(Result.error(tFailure)),
      build: buildCubit,
      seed: () => PostsState(posts: AsyncData([tPost])),
      // when
      act: (cubit) => cubit.create(title: tTitle, content: tContent),
      // then
      expect: () => [
        PostsState(posts: AsyncData([tPost]), createPost: const AsyncLoading()),
        PostsState(posts: AsyncData([tPost]), createPost: AsyncError(tFailure)),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts are loaded but empty
      AND the create post use case answers with the new post
      WHEN create is called with a title and a content
      THEN it ends with a state whose list has the new post as its only post''',
      // given
      setUp: () => setUpMockCreatePost(Result.ok(tNewPost)),
      build: buildCubit,
      seed: () => const PostsState(posts: AsyncData([])),
      // when
      act: (cubit) => cubit.create(title: tTitle, content: tContent),
      // then
      expect: () => [
        const PostsState(posts: AsyncData([]), createPost: AsyncLoading()),
        PostsState(
          posts: AsyncData([tNewPost]),
          createPost: AsyncData(tNewPost),
        ),
      ],
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts are loaded
      AND whose post creation is already loading
      WHEN create is called a second time
      THEN it emits nothing
      AND the create post use case is never called''',
      // given
      build: buildCubit,
      seed: () => PostsState(
        posts: AsyncData([tPost]),
        createPost: const AsyncLoading(),
      ),
      // when
      act: (cubit) => cubit.create(title: tTitle, content: tContent),
      // then
      expect: () => const <PostsState>[],
      verify: (_) => verifyCreatePostWasNeverCalled(),
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit that has not loaded its posts yet
      WHEN create is called
      THEN it emits nothing, because there is no list to add the new post to
      AND the create post use case is never called''',
      // given
      build: buildCubit,
      // when
      act: (cubit) => cubit.create(title: tTitle, content: tContent),
      // then
      expect: () => const <PostsState>[],
      verify: (_) => verifyCreatePostWasNeverCalled(),
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts are still loading
      WHEN create is called
      THEN it emits nothing
      AND the create post use case is never called''',
      // given
      build: buildCubit,
      seed: () => const PostsState(posts: AsyncLoading()),
      // when
      act: (cubit) => cubit.create(title: tTitle, content: tContent),
      // then
      expect: () => const <PostsState>[],
      verify: (_) => verifyCreatePostWasNeverCalled(),
    );

    blocTest<PostsCubit, PostsState>(
      '''
      GIVEN a cubit whose posts failed to load
      WHEN create is called
      THEN it emits nothing
      AND the create post use case is never called''',
      // given
      build: buildCubit,
      seed: () => PostsState(posts: AsyncError(tFailure)),
      // when
      act: (cubit) => cubit.create(title: tTitle, content: tContent),
      // then
      expect: () => const <PostsState>[],
      verify: (_) => verifyCreatePostWasNeverCalled(),
    );
  });
}
