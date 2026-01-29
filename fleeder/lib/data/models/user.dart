import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final List<String> followers;
  final List<String> following;
  final List<String> likedPosts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    this.username = '',
    this.displayName = '',
    this.bio = '',
    this.followers = const [],
    this.following = const [],
    this.likedPosts = const [],
    required this.createdAt,
    this.updatedAt,
  });

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

  User copyWith({
    String? username,
    String? displayName,
    String? bio,
    List<String>? followers,
    List<String>? following,
    List<String>? likedPosts,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      likedPosts: likedPosts ?? this.likedPosts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  User follow(String userId) {
    if (following.contains(userId)) return this;
    return copyWith(
      following: [...following, userId],
      updatedAt: DateTime.now(),
    );
  }

  User unfollow(String userId) {
    return copyWith(
      following: following.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  User updateDisplayName(String newName) {
    return copyWith(
      displayName: newName,
      updatedAt: DateTime.now(),
    );
  }

  User updateBio(String newBio) {
    return copyWith(
      bio: newBio,
      updatedAt: DateTime.now(),
    );
  }

  User likePost(String postId) {
    if (likedPosts.contains(postId)) return this;
    return copyWith(
      likedPosts: [...likedPosts, postId],
      updatedAt: DateTime.now(),
    );
  }

  User unlikePost(String postId) {
    return copyWith(
      likedPosts: likedPosts.where((id) => id != postId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  bool isFollowingUser(String userId) => following.contains(userId);

  User removeFollower(String userId) {
    return copyWith(
      followers: followers.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }
}

