import '../entities/post.dart';

abstract interface class PostsRepository {
  Future<List<Post>> getPosts();

  Future<Post> createPost({required String title, required String content});
}
