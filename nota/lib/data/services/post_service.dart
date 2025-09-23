import 'package:nota/data/mock/mock_posts.dart';
import 'package:nota/data/models/post.dart';

class PostService {
  static Future<List<Post>> fetchPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPosts;
  }

  static Future<List<Post>> fetchPostsByUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPosts.where((post) => post.authorId == userId).toList();
  }

  static Future<void> addPost(String userId, String title, String content) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final newPost = Post(
      id: 'post${mockPosts.length + 1}',
      authorId: userId,
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );

    mockPosts.add(newPost);
  }
}