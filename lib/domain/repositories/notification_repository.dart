import 'package:fleeds/data/dtos/notification_dto.dart';

/// Repository interface for Notification-related data operations.
/// Defines methods for fetching, adding, and manipulating notifications.
/// Implementations of this interface will handle the actual data source interactions.
abstract class NotificationRepository {

  Future<({List<NotificationDTO> notifications, String? lastDocId})> fetchNotificationsForUser({
    required String userId,
    int limit = 20,
    String? startAfterId,
  });

  Future<List<NotificationDTO>> fetchUnreadNotificationsForUser(String userId);

  Future<void> addNotification({
    required String type,
    required String targetUserId,
    required String triggeredByUsername,
    required String triggeredByUserId,
    String? relatedPostId,
  });

  Future<void> markNotificationAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
}