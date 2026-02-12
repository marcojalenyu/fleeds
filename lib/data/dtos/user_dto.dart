import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for User
/// Maps Firestore data to UserDTO instances
/// Includes factory constructor for Firestore mapping
class UserDTO {
  final String id;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final String avatarColor;
  final String avatarBgColor;
  final String bannerUrl;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserDTO({
    required this.id,
    this.username = '',
    this.displayName = '',
    this.bio = '',
    this.avatarUrl = '',
    this.avatarColor = '',
    this.avatarBgColor = '',
    this.bannerUrl = '',
    this.followers = const [],
    this.following = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory UserDTO.fromFirestore(String id, Map<String, dynamic> data, {String? email}) {
    return UserDTO(
      id: id,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      avatarColor: data['avatarColor'] ?? '',
      avatarBgColor: data['avatarBgColor'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}


