class User {
  final String id;
  String username;
  String password;
  String displayName;
  final DateTime createdAt;
  DateTime? updatedAt;
  List<String> likedPosts = []; // List of post IDs the user has liked

  User({
    required this.id,
    this.username = '',
    this.password = '',
    this.displayName = '',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  void likePost(String postId) {
    if (!likedPosts.contains(postId)) {
      likedPosts.add(postId);
    }
  }

  void unlikePost(String postId) {
    likedPosts.remove(postId);
  }
}