class Post {
  final String _id;
  final String _authorId;
  
  final String _content;
  String? _imageUrl;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  bool deleted = false;
  final List<String> _likes; // List of user IDs who liked the post
  final List<String> _comments; // List of comment IDs associated with the post

  String get id => _id;
  String get content => _content;
  String get authorId => _authorId;
  DateTime get createdAt => _createdAt ?? DateTime.now();
  int get likeCount => _likes.length;
  int get commentCount => _comments.length;

  Post({
    required String id,
    required String authorId,
    String content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? likes,
    List<String>? comments,
  })  : 
    _id = id,
    _authorId = authorId,
    _content = content,
    _createdAt = createdAt,
    _updatedAt = updatedAt,
    _likes = likes ?? [],
    _comments = comments ?? [];

  bool likedBy(String userId) {
    return _likes.contains(userId);
  }

  bool toggleLike(String userId) {
    if (likedBy(userId)) {
      _likes.remove(userId);
      return false;
    } else {
      _likes.add(userId);
      return true;
    }
  }
}