import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/create_post_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsRepository extends Mock implements PostsRepository;

void main() {
  late CreatePostUseCase usecase;
  late MockPostsRepository mockPostsRepository;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    usecase = CreatePostUseCase(mockPostsRepository);
  });

  const tTitle = 'Test title';
  const tContent = 'Test content';
  final tResult = Result.ok(
    Post(
      id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
      title: tTitle,
      content: tContent,
      createdAt: DateTime.utc(2026, 1, 2, 12, 30),
    ),
  );

  test(
    '''
    GIVEN a signed in user
    WHEN the create post use case is called with a title and a content
    THEN the Ok result with the created post from the repository is returned
    AND the repository was asked to create a post with the same title and
        content
    AND nothing else was asked of the repository''',
    () async {
      // given
      when(
        () => mockPostsRepository.createPost(
          title: any(named: 'title'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => tResult);
      // when
      final result = await usecase(title: tTitle, content: tContent);
      // then
      expect(result, same(tResult));
      verify(
        () => mockPostsRepository.createPost(title: tTitle, content: tContent),
      ).called(1);
      verifyNoMoreInteractions(mockPostsRepository);
    },
  );
}
