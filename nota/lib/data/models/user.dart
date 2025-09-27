class User {
  final String id;
  String username;
  String password;
  String displayName;

  final DateTime createdAt;
  DateTime? updatedAt;

  String bio = '';
  List<String> followers = []; // List of user IDs who follow this user
  List<String> following = []; // List of user IDs this user follows
  List<String> likedPosts = []; // List of post IDs the user has liked

  User({
    required this.id,
    this.username = '',
    this.password = '',
    this.displayName = '',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  void updateBio(String newBio) {
    bio = newBio;
    updatedAt = DateTime.now();
  }

  void likePost(String postId) {
    if (!likedPosts.contains(postId)) {
      likedPosts.add(postId);
      updatedAt = DateTime.now();
    }
  }

  void unlikePost(String postId) {
    likedPosts.remove(postId);
    updatedAt = DateTime.now();
  }

  void followUser(String userId) {
    if (!following.contains(userId)) {
      following.add(userId);
      updatedAt = DateTime.now();
    }
  }

  void unfollowUser(String userId) {
    following.remove(userId);
    updatedAt = DateTime.now();
  }

  bool isFollowingUser(String userId) {
    return following.contains(userId);
  }

  void removeFollower(String userId) {
    followers.remove(userId);
    updatedAt = DateTime.now();
  }
}