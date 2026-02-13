import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for Notification
/// Maps Firestore data to NotificationDTO instances
/// Includes factory constructor for Firestore mapping
class NotificationDTO {
  final String id;
  final String type; // e.g., "like", "reply", "follow"
  final String targetUserId; // ID of the user who should receive the notification
  final String triggeredByUsername; // Username of the user who triggered the notification
  final String triggeredByUserId; // ID of the user who triggered the notification
  final String? relatedPostId; // ID of the related post, if applicable
  final bool read;
  final DateTime createdAt;
  final bool deleted;

  const NotificationDTO({
    required this.id,
    required this.type,
    required this.targetUserId,
    required this.triggeredByUsername,
    required this.triggeredByUserId,
    this.relatedPostId,
    this.read = false,
    required this.createdAt,
    this.deleted = false,
  });

  /// Factory for Firestore mapping
  factory NotificationDTO.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationDTO(
      id: id,
      type: data['type'] ?? '',
      targetUserId: data['targetUserId'] ?? '',
      triggeredByUsername: data['triggeredByUsername'] ?? '',
      triggeredByUserId: data['triggeredByUserId'] ?? '',
      relatedPostId: data['relatedPostId'],
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deleted: data['deleted'] ?? false,
    );
  }
}