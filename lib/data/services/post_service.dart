import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/dtos/post_dto.dart';
import 'package:fleeds/data/repositories/post_repository_impl.dart';
import 'package:fleeds/data/services/notification_service.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/repositories/post_repository.dart';

/// Service class that interacts with PostRepository to perform operations related to posts.
/// Maps PostDTOs to Post domain models.
class PostService {
  final PostRepository _repository;
  final NotificationService _notificationService;

  const PostService({PostRepository? repository, NotificationService? notificationService})
      : _repository = repository ?? const PostRepositoryImpl(),
        _notificationService = notificationService ?? const NotificationService();

  Post _mapDtoToDomain(PostDTO dto) {
    return Post(
      id: dto.id,
      authorId: dto.authorId,
      repliedToPostId: dto.repliedToPostId,
      content: dto.content,
      mediaUrl: dto.mediaUrl,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      deleted: dto.deleted,
      likes: List<String>.from(dto.likes),
      replies: List<String>.from(dto.comments),
    );
  }

  Future<Post?> fetchPost(String postId) async {
    final dto = await _repository.fetchPost(postId);
    if (dto == null) return null;
    return _mapDtoToDomain(dto);
  }

  Future<({List<Post> posts, DocumentSnapshot? lastDoc})> fetchPostsByKeyword({
  List<String> keywords = const [],
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  final result = await _repository.fetchPostsByKeyword(
    keywords: keywords,
    limit: limit,
    startAfter: startAfter,
  );
  final posts = result.posts.map(_mapDtoToDomain).toList();
  return (posts: posts, lastDoc: result.lastDoc);
}

Future<({List<Post> posts, DocumentSnapshot? lastDoc})> fetchPostsByUser({
  required String userId,
  int limit = 20,  
  DocumentSnapshot? startAfter,
}) async {
  final result = await _repository.fetchPostsByUser(
    userId: userId,
    limit: limit,
    startAfter: startAfter,
  );
  final posts = result.posts.map(_mapDtoToDomain).toList();
  return (posts: posts, lastDoc: result.lastDoc);
}

Future<({List<Post> posts, DocumentSnapshot? lastDoc})> fetchPostsLikedByUser({
  required String userId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  final result = await _repository.fetchPostsLikedByUser(
    userId: userId,
    limit: limit,
    startAfter: startAfter,
  );
  final posts = result.posts.map(_mapDtoToDomain).toList();
  return (posts: posts, lastDoc: result.lastDoc);
}

Future<({List<Post> posts, DocumentSnapshot? lastDoc})> fetchRepliesByUser({
  required String userId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  final result = await _repository.fetchRepliesByUser(
    userId: userId,
    limit: limit,
    startAfter: startAfter,
  );
  final posts = result.posts.map(_mapDtoToDomain).toList();
  return (posts: posts, lastDoc: result.lastDoc);
}

Future<({List<Post> posts, DocumentSnapshot? lastDoc})> fetchReplies({
  required String postId,
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  final result = await _repository.fetchReplies(
    postId: postId,
    limit: limit,
    startAfter: startAfter,
  );
  final posts = result.posts.map(_mapDtoToDomain).toList();
  return (posts: posts, lastDoc: result.lastDoc);
}

  Future<String?> addPost({required String content, required String authorId, String? mediaUrl}) async {
    return await _repository.addPost(content, authorId, mediaUrl);
  }

  Future<String?> addReply({
    required String content, 
    required String authorId, 
    required String authorUsername,
    required String repliedToPostId,
    required String repliedToPostAuthorId,
  }) async {
    final replyId = await _repository.addReply(content, authorId, repliedToPostId);
    if (replyId != null) {
      await _notificationService.addNotification(
        type: 'reply',
        triggeredByUserId: authorId,
        triggeredByUsername: authorUsername,
        targetUserId: repliedToPostAuthorId,
        relatedPostId: repliedToPostId,
      );
    }
    return replyId;  
  }

  Future<List<String>?> toggleLike(
    String postId,
    String postAuthorId, 
    String userId,
    String username,
  ) async {
    final updatedLikes = await _repository.toggleLike(postId, userId);
    if (updatedLikes != null && updatedLikes.contains(userId)) {
      await _notificationService.addNotification(
        type: 'like',
        triggeredByUserId: userId,
        triggeredByUsername: username,
        targetUserId: postAuthorId,
        relatedPostId: postId,
      );
    }
    return updatedLikes;
  }
}