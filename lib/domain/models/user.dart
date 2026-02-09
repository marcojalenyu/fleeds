/// A model representing a user in the social media application.
/// Contains user details such as ID, username, bio, avatar URL, followers, and following
/// Converted from UserDTO for domain layer usage.
class User {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl; // URL to the user's avatar image
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.followers,
    required this.following,
    required this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    List<String>? followers,
    List<String>? following,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Follow or unfollow a user by their ID.
  User toggleFollow(String userId) {
    List<String> following = List.from(this.following);
    if (following.contains(userId)) {
      following.remove(userId);
    } else {
      following.add(userId);
    }
    return copyWith(
      following: following, 
      updatedAt: DateTime.now()
    );
  }

  /// Update the display name of the user.
  User updateDisplayName(String newDisplayName) {
    return copyWith(
      displayName: newDisplayName, 
      updatedAt: DateTime.now()
    );
  }

  /// Update the bio of the user.
  User updateBio(String newBio) {
    return copyWith(
      bio: newBio, 
      updatedAt: DateTime.now()
    );
  }

  /// TODO: Implement avatar URL update method if needed.

  User addFollower(String userId) {
    List<String> followers = List.from(this.followers);
    if (!followers.contains(userId) && userId != id) {
      followers.add(userId);
    }
    return copyWith(
      followers: followers, 
      updatedAt: DateTime.now()
    );
  }

  /// Remove a follower by their user ID.
  User removeFollower(String userId) {
    return copyWith(
      followers: followers.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Check if the user is following another user by their ID.
  bool isFollowingUser(String userId) {
    return following.contains(userId);
  }
}