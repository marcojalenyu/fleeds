/// A model representing a notification in the social media application.
/// Contains details such as the type of notification, the user who triggered it,
/// the related post (if applicable), and timestamps.
/// Converted from NotificationDTO for domain layer usage.
class Notification {
  final String id;
  final String type; // e.g., "like", "reply", "follow"
  final String targetUserId; // ID of the user who should receive the notification
  final String triggeredByUsername; // Username of the user who triggered the notification
  final String triggeredByUserId; // ID of the user who triggered the notification
  final String? relatedPostId; // ID of the related post, if applicable
  final bool read;
  final DateTime createdAt;
  final bool deleted;

  bool get isRead => read;
  
  Notification({
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

  Notification copyWith({
    String? type,
    String? targetUserId,
    String? triggeredByUsername,
    String? triggeredByUserId,
    String? relatedPostId,
    bool? read,
    DateTime? createdAt,
    bool? deleted,
  }) {
    return Notification(
      id: id,
      type: type ?? this.type,
      targetUserId: targetUserId ?? this.targetUserId,
      triggeredByUsername: triggeredByUsername ?? this.triggeredByUsername,
      triggeredByUserId: triggeredByUserId ?? this.triggeredByUserId,
      relatedPostId: relatedPostId ?? this.relatedPostId,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      deleted: deleted ?? this.deleted,
    );
  }

  /// Mark the notification as read.
  Notification markAsRead() {
    return copyWith(read: true);
  }

  /// Mark the notification as deleted (soft delete).
  Notification markAsDeleted() {
    return copyWith(deleted: true);
  }

  /// Get a user-friendly display text based on the notification type.
  String get displayBody {
    switch (type) {
      case 'like':
        return 'liked your post';
      case 'reply':
        return 'replied to your post';
      case 'follow':
        return 'started following you';
      default:
        return 'performed an action';
    }
  }
}