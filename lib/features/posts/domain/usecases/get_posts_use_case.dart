import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPostsUseCase(final PostsRepository _repository) {
  Future<List<Post>> call() => _repository.getPosts();
}
