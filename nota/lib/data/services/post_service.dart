import 'package:nota/data/mock/mock_posts.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/services/user_service.dart';

class PostService {

  static Future<List<Post>> fetchPostsLikedByUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final user = UserService.getUserById(userId);
    if (user == null) {
      return [];
    }
    
    return mockPosts.where((post) => user.likedPosts.contains(post.id)).toList();
  }

  static Future<List<Post>> fetchPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    List<Post> posts = List.from(mockPosts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  static Future<List<Post>> fetchPostsByUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return mockPosts.where((post) => post.authorId == userId).toList();
  }

  static Future<void> addPost(String userId, String content) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final newPost = Post(
      id: 'post${mockPosts.length + 1}',
      authorId: userId,
      content: content,
      createdAt: DateTime.now(),
    );

    mockPosts.add(newPost);
  }

  static Future<void> likePost(String postId, String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final post = mockPosts.firstWhere((post) => post.id == postId);
    UserService.likePost(userId, postId, post.toggleLike(userId));
  }
}