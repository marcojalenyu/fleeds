/// A model representing a user in the social media application.
/// Contains user details such as ID, username, bio, avatar URL, followers, and following
/// Converted from UserDTO for domain layer usage.
class User {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl; // URL to the user's avatar image
  final String avatarColor; // Hex color code for avatar background
  final String avatarBgColor; // Hex color code for avatar background
  final String bannerUrl; // URL to the user's banner image
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
    required this.avatarColor,
    required this.avatarBgColor,
    required this.bannerUrl,
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
    String? avatarColor,
    String? avatarBgColor,
    String? bannerUrl,
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
      avatarColor: avatarColor ?? this.avatarColor,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
      bannerUrl: bannerUrl ?? this.bannerUrl,
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

  /// Update the user's username
  User updateUsername(String newUsername) {
    return copyWith(
      username: newUsername,
      updatedAt: DateTime.now(),
    );
  }

  /// Update the profile details of the user, such as avatar and banner URLs and colors.
  User updateProfile({
    String newDisplayName = '',
    String newBio = '',
    String? avatarUrl,
    String? avatarColor,
    String? avatarBgColor,
    String? bannerUrl,
  }) {
    return copyWith(
      displayName: newDisplayName.isNotEmpty ? newDisplayName : displayName,
      bio: newBio.isNotEmpty ? newBio : bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarBgColor: avatarBgColor ?? this.avatarBgColor,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      updatedAt: DateTime.now(),
    );
  }

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