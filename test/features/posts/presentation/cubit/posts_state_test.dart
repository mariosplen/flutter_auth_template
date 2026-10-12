// The states are created at runtime on purpose: two const states are the very
// same instance, which would not prove that they are compared by value.
// ignore_for_file: prefer_const_constructors

import 'package:flutter_auth_template/core/error/async_value.dart';
import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/presentation/cubit/posts_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tPost = Post(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: 'Test title',
    content: 'Test content',
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );
  final tFailure = ServerFailure(Exception('connection refused'));

  test(
    '''
    GIVEN nothing was requested yet
    WHEN a PostsState is created without any arguments
    THEN its posts are initial
    AND its post creation is initial''',
    () {
      // when
      final state = PostsState();

      // then
      expect(state.posts, AsyncInitial<List<Post>>());
      expect(state.createPost, AsyncInitial<Post>());
    },
  );

  group('equality', () {
    test(
      '''
      GIVEN two PostsStates with equal lists of posts and equal post creations
      WHEN they are compared
      THEN they are equal, even though the two lists are different instances''',
      () {
        // given
        final first = PostsState(
          posts: AsyncData([tPost]),
          createPost: AsyncData(tPost),
        );
        final second = PostsState(
          posts: AsyncData([tPost]),
          createPost: AsyncData(tPost),
        );

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two PostsStates that only differ in their posts
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = PostsState(posts: AsyncData([tPost]));
        final second = PostsState(posts: AsyncData([]));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two PostsStates that only differ in their post creation
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = PostsState(createPost: AsyncLoading());
        final second = PostsState(createPost: AsyncError(tFailure));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });

  group('copyWith', () {
    test(
      '''
      GIVEN a PostsState whose posts are loaded
      WHEN it is copied with a loading post creation
      THEN the copy has the loading post creation
      AND the copy keeps the loaded posts''',
      () {
        // given
        final state = PostsState(posts: AsyncData([tPost]));

        // when
        final copy = state.copyWith(createPost: AsyncLoading());

        // then
        expect(
          copy,
          PostsState(posts: AsyncData([tPost]), createPost: AsyncLoading()),
        );
      },
    );
  });
}
