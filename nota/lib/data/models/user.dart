import 'package:cloud_firestore/cloud_firestore.dart';

class User {

  final String id;
  String username;
  String displayName;
  String bio = '';
 
  List<String> followers = []; // List of user IDs who follow this user
  List<String> following = []; // List of user IDs this user follows
  List<String> likedPosts = []; // List of post IDs the user has liked

  final DateTime createdAt;
  DateTime? updatedAt;

  factory User.fromFirestore(String id, Map<String, dynamic> data, {String? email}) {
    return User(
      id: id,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      likedPosts: List<String>.from(data['likedPosts'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  User({
    required this.id,
    this.username = '',
    this.displayName = '',
    this.bio = '',
    this.followers = const [],
    this.following = const [],
    this.likedPosts = const [],
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  void updateDisplayName(String newName) {
    displayName = newName;
    updatedAt = DateTime.now();
  }

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