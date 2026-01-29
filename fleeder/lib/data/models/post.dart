import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String repliedToPostId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool deleted;
  final List<String> likes; // List of user IDs who liked the post
  final List<String> comments; // List of comment IDs associated with the post

  int get likeCount => likes.length;
  int get commentCount => comments.length;

  const Post({
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
  factory Post.fromFirestore(String id, Map<String, dynamic> data) {
    return Post(
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

  Post copyWith({
    String? authorId,
    String? repliedToPostId,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    List<String>? likes,
    List<String>? comments,
  }) {
    return Post(
      id: id,
      authorId: authorId ?? this.authorId,
      repliedToPostId: repliedToPostId ?? this.repliedToPostId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  bool likedBy(String userId) => likes.contains(userId);

  Post toggleLike(String userId) {
    if (likedBy(userId)) {
      return copyWith(
        likes: likes.where((id) => id != userId).toList(),
        updatedAt: DateTime.now(),
      );
    } else {
      return copyWith(
        likes: [...likes, userId],
        updatedAt: DateTime.now(),
      );
    }
  }

  bool isAReply({String originalPostId = ''}) {
    return repliedToPostId.isNotEmpty &&
        (repliedToPostId == originalPostId || originalPostId.isEmpty);
  }

  Post addReply(String replyId) {
    final updatedComments = [...comments, replyId]..sort();
    return copyWith(
      comments: updatedComments,
      updatedAt: DateTime.now(),
    );
  }
}

