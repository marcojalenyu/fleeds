import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/dtos/post_dto.dart';
import 'package:fleeds/data/repositories/post_repository_impl.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/repositories/post_repository.dart';

/// Service class that interacts with PostRepository to perform operations related to posts.
/// Maps PostDTOs to Post domain models.
class PostService {
  final PostRepository _repository;

  const PostService({PostRepository? repository})
      : _repository = repository ?? const PostRepositoryImpl();

  Post _mapDtoToDomain(PostDTO dto) {
    return Post(
      id: dto.id,
      authorId: dto.authorId,
      repliedToPostId: dto.repliedToPostId,
      content: dto.content,
      imageUrl: dto.imageUrl,
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

  Future<String?> addPost({required String content, required String authorId}) async {
    return await _repository.addPost(content, authorId);
  }

  Future<String?> addReply({required String content, required String authorId, required String repliedToPostId}) async {
    return await _repository.addReply(content, authorId, repliedToPostId);
  }

  Future<List<String>?> toggleLike(String postId, String userId) async {
    return await _repository.toggleLike(postId, userId);
  }
}