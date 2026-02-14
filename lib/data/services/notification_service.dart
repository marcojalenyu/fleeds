import 'package:fleeds/data/dtos/notification_dto.dart';
import 'package:fleeds/data/repositories/notification_repository_impl.dart';
import 'package:fleeds/domain/models/notification.dart';
import 'package:fleeds/domain/repositories/notification_repository.dart';

/// Service class that interacts with NotificationRepository to perform operations related to notifications.
/// Maps NotificationDTOs to Notification domain models.
class NotificationService {
  final NotificationRepository _repository;

  const NotificationService({NotificationRepository? repository})
      : _repository = repository ?? const NotificationRepositoryImpl();

  Notification _mapDtoToDomain(NotificationDTO dto) {
    return Notification(
      id: dto.id,
      type: dto.type,
      targetUserId: dto.targetUserId,
      triggeredByUsername: dto.triggeredByUsername,
      triggeredByUserId: dto.triggeredByUserId,
      relatedPostId: dto.relatedPostId,
      read: dto.read,
      createdAt: dto.createdAt,
      deleted: dto.deleted,
    );
  }

  Future<({List<Notification> notifications, String? lastDocId})> fetchNotificationsForUser({
    required String userId,
    int limit = 20,
    String? startAfterId,
  }) async {
    final result = await _repository.fetchNotificationsForUser(
      userId: userId,
      limit: limit,
      startAfterId: startAfterId,
    );
    final notifications = result.notifications.map(_mapDtoToDomain).toList();
    return (notifications: notifications, lastDocId: result.lastDocId);
  }

  Future<void> addNotification({
    required String type,
    required String targetUserId,
    required String triggeredByUsername,
    required String triggeredByUserId,
    String? relatedPostId,
  }) async {
    if (targetUserId != triggeredByUserId) {
      await _repository.addNotification(
        type: type,
        targetUserId: targetUserId,
        triggeredByUsername: triggeredByUsername,
        triggeredByUserId: triggeredByUserId,
        relatedPostId: relatedPostId,
      );
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _repository.markNotificationAsRead(notificationId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _repository.deleteNotification(notificationId);
  }
}