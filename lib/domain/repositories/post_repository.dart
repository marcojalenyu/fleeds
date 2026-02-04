import '../../data/dtos/post_dto.dart';

/// Repository interface for Post-related data operations.
/// Defines methods for fetching, adding, and manipulating posts.
/// Implementations of this interface will handle the actual data source interactions.  
abstract class PostRepository {
  Future<PostDTO?> fetchPost(String postId);
  Future<List<PostDTO>> fetchPostsByKeyword({List<String> keywords = const []});
  Future<List<PostDTO>> fetchPostsByUser(String userId);
  Future<List<PostDTO>> fetchPostsLikedByUser(String userId);
  Future<List<PostDTO>> fetchReplies(String postId);
  Future<String?> addPost(String content, String authorId);
  Future<String?> addReply(String content, String authorId, String repliedToPostId);
  Future<List<String>?> toggleLike(String postId, String userId);
}