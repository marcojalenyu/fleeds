import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/dtos/post_dto.dart';

/// Repository interface for Post-related data operations.
/// Defines methods for fetching, adding, and manipulating posts.
/// Implementations of this interface will handle the actual data source interactions.  
abstract class PostRepository {

  Future<PostDTO?> fetchPost(String postId);

  Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchPostsByKeyword({
    List<String> keywords = const [],
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
  
  Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchPostsByUser({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
  
  Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchPostsLikedByUser({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });

  Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchRepliesByUser({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });

  Future<({List<PostDTO> posts, DocumentSnapshot? lastDoc})> fetchReplies({
    required String postId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  });

  Future<String?> addPost(String content, String authorId, String? mediaUrl);
  Future<String?> addReply(String content, String authorId, String repliedToPostId);
  Future<List<String>?> toggleLike(String postId, String userId);
}