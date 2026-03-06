/// A model representing a social media post.
/// Includes details such as author, content, timestamps, likes, and comments.
/// Converted from PostDTO for domain layer usage.
class Post {
  final String id;
  final String authorId;
  final String repliedToPostId; /// ID of the post this is replying to, if any.
  final String content;
  final String? mediaUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool deleted;
  final List<String> likes;
  final List<String> replies;

  Post({
    required this.id,
    required this.authorId,
    required this.repliedToPostId,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    this.updatedAt,
    this.deleted = false,
    this.likes = const [],
    this.replies = const [],
  });

  Post copyWith({
    String? authorId,
    String? repliedToPostId,
    String? content,
    String? mediaUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
    List<String>? likes,
    List<String>? replies,
  }) {
    return Post(
      id: id,
      authorId: authorId ?? this.authorId,
      repliedToPostId: repliedToPostId ?? this.repliedToPostId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
    );
  }

  int get likeCount => likes.length;
  int get replyCount => replies.length;
  bool get isReply => repliedToPostId.isNotEmpty;

  /// Check if the post is liked by a specific user.
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  /// Like or unlike the post by a user.
  Post toggleLike(String userId) {
    final updatedLikes = List<String>.from(likes);
    if (isLikedBy(userId)) {
      updatedLikes.remove(userId);
    } else {
      updatedLikes.add(userId);
    }
    return copyWith(
      likes: updatedLikes, 
      updatedAt: DateTime.now()
    );
  }  

  /// Add a reply to the post.
  Post addReply(String replyId) {
    final updatedReplies = List<String>.from(replies)..add(replyId);
    return copyWith(
      replies: updatedReplies, 
      updatedAt: DateTime.now()
    );
  }

  /// Checks if new post content is valid (non-empty and within length limits).
  static bool isValid(String content, {int maxLength = 128}) {
    return content.trim().isNotEmpty && content.length <= maxLength;
  }
}