import 'package:flutter_auth_template/core/error/result.dart';
import 'package:flutter_auth_template/features/posts/domain/entities/post.dart';
import 'package:flutter_auth_template/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_auth_template/features/posts/domain/usecases/get_posts_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostsRepository extends Mock implements PostsRepository;

void main() {
  late GetPostsUseCase usecase;
  late MockPostsRepository mockPostsRepository;

  setUp(() {
    mockPostsRepository = MockPostsRepository();
    usecase = GetPostsUseCase(mockPostsRepository);
  });

  final tResult = Result.ok([
    Post(
      id: '0c9e7b52-3f6d-4a18-b2c4-7d8e9f0a1b2c',
      title: 'Test title',
      content: 'Test content',
      createdAt: DateTime.utc(2026, 1, 2, 12, 30),
    ),
  ]);

  test(
    '''
    GIVEN there are posts on the server
    WHEN the get posts use case is called
    THEN the Ok result with the posts from the repository is returned
    AND only the posts were asked of the repository''',
    () async {
      // given
      when(() => mockPostsRepository.getPosts())
          .thenAnswer((_) async => tResult);
      // when
      final result = await usecase();
      // then
      expect(result, same(tResult));
      verify(() => mockPostsRepository.getPosts()).called(1);
      verifyNoMoreInteractions(mockPostsRepository);
    },
  );
}
