import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tId = '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c';
  const tTitle = 'Test title';
  const tContent = 'Test content';
  final tCreatedAt = DateTime.utc(2026, 1, 2, 12, 30);

  Post buildPost({
    String id = tId,
    String title = tTitle,
    String content = tContent,
    DateTime? createdAt,
  }) => Post(
    id: id,
    title: title,
    content: content,
    createdAt: createdAt ?? tCreatedAt,
  );

  test(
    '''
    GIVEN an id, a title, a content and a creation date
    WHEN a Post is created with them
    THEN the Post holds that id, title, content and creation date''',
    () {
      // when
      final post = Post(
        id: tId,
        title: tTitle,
        content: tContent,
        createdAt: tCreatedAt,
      );

      // then
      expect(post.id, tId);
      expect(post.title, tTitle);
      expect(post.content, tContent);
      expect(post.createdAt, tCreatedAt);
    },
  );

  group('equality', () {
    test(
      '''
      GIVEN two Posts with the same id, title, content and creation date
      WHEN they are compared
      THEN they are equal''',
      () {
        // given
        final first = buildPost();
        final second = buildPost();

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isTrue);
      },
    );

    test(
      '''
      GIVEN two Posts that only differ in their id
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = buildPost();
        final second = buildPost(id: 'another-id');

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two Posts that only differ in their title
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = buildPost();
        final second = buildPost(title: 'Another title');

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two Posts that only differ in their content
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = buildPost();
        final second = buildPost(content: 'Another content');

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );

    test(
      '''
      GIVEN two Posts that only differ in their creation date
      WHEN they are compared
      THEN they are not equal''',
      () {
        // given
        final first = buildPost();
        final second = buildPost(createdAt: DateTime.utc(2027));

        // when
        final areEqual = first == second;

        // then
        expect(areEqual, isFalse);
      },
    );
  });
}
