import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/create_post_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late CreatePostUseCase useCase;
  late MockPostsRepository mockPostsRepository;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    useCase = CreatePostUseCase(mockPostsRepository);
  });

  const tTitle = 'Test title';
  const tContent = 'Test content';
  final tPost = Post(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: tTitle,
    content: tContent,
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );

  void setUpMockPostsRepositoryCreatePost(Result<Post> result) {
    when(
      () => mockPostsRepository.createPost(
        title: any(named: 'title'),
        content: any(named: 'content'),
      ),
    ).thenAnswer((_) async => result);
  }

  test(
    '''
    GIVEN the repository creates the post and answers with an Ok
    WHEN the use case is called with a title and a content
    THEN the repository is asked to create a post exactly once
         with that title and that content
    AND the Ok of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result.ok(tPost);
      setUpMockPostsRepositoryCreatePost(tResult);

      // when
      final result = await useCase(title: tTitle, content: tContent);

      // then
      expect(result, same(tResult));
      verify(
        () => mockPostsRepository.createPost(title: tTitle, content: tContent),
      ).called(1);
      verifyNoMoreInteractions(mockPostsRepository);
    },
  );

  test(
    '''
    GIVEN the repository cannot create the post and answers with an Error
    WHEN the use case is called with a title and a content
    THEN the Error of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result<Post>.error(
        ServerFailure(Exception('connection refused')),
      );
      setUpMockPostsRepositoryCreatePost(tResult);

      // when
      final result = await useCase(title: tTitle, content: tContent);

      // then
      expect(result, same(tResult));
      verify(
        () => mockPostsRepository.createPost(title: tTitle, content: tContent),
      ).called(1);
      verifyNoMoreInteractions(mockPostsRepository);
    },
  );
}
