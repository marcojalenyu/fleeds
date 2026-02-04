import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for Post
/// Maps Firestore data to PostDTO instances
/// Includes factory constructor for Firestore mapping
class PostDTO {
  final String id;
  final String authorId;
  final String repliedToPostId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool deleted;
  final List<String> likes;
  final List<String> comments;

  const PostDTO({
    required this.id,
    required this.authorId,
    this.repliedToPostId = '',
    this.content = '',
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.deleted = false,
    this.likes = const [],
    this.comments = const [],
  });

  // Factory for Firestore mapping
  factory PostDTO.fromFirestore(String id, Map<String, dynamic> data) {
    return PostDTO(
      id: id,
      authorId: data['authorId'] ?? '',
      repliedToPostId: data['repliedToPostId'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deleted: data['deleted'] ?? false,
      likes: List<String>.from(data['likes'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
    );
  }
}


