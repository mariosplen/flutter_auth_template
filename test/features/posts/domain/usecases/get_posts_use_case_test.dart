import 'package:flutter_auth_template/core/error/failures.dart';
import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/get_posts_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late GetPostsUseCase useCase;
  late MockPostsRepository mockPostsRepository;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    useCase = GetPostsUseCase(mockPostsRepository);
  });

  final tPost = Post(
    id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
    title: 'Test title',
    content: 'Test content',
    createdAt: DateTime.utc(2026, 1, 2, 12, 30),
  );

  test(
    '''
    GIVEN the repository loads the posts and answers with an Ok
    WHEN the use case is called
    THEN the repository is asked for the posts exactly once
    AND the Ok of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result.ok([tPost]);
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => tResult);

      // when
      final result = await useCase();

      // then
      expect(result, same(tResult));
      verify(() => mockPostsRepository.getPosts()).called(1);
      verifyNoMoreInteractions(mockPostsRepository);
    },
  );

  test(
    '''
    GIVEN the repository cannot load the posts and answers with an Error
    WHEN the use case is called
    THEN the Error of the repository is returned as it is''',
    () async {
      // given
      final tResult = Result<List<Post>>.error(
        ServerFailure(Exception('connection refused')),
      );
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => tResult);

      // when
      final result = await useCase();

      // then
      expect(result, same(tResult));
      verify(() => mockPostsRepository.getPosts()).called(1);
      verifyNoMoreInteractions(mockPostsRepository);
    },
  );
}
