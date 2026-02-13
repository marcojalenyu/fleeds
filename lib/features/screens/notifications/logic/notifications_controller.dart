import 'package:flutter/material.dart' hide Notification;
import 'package:fleeds/domain/models/notification.dart';
import 'package:fleeds/data/services/notification_service.dart';

/// Controller for managing the state of the notifications screen, fetching and manipulating notifications for the user
class NotificationsController extends ChangeNotifier {
  final NotificationService _service;

  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _lastDocId;
  bool _hasMore = true;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  NotificationsController({NotificationService? service})
      : _service = service ?? const NotificationService();

  /// Resets pagination state for fetching notifications
  void resetPagination() {
    _lastDocId = null;
    _hasMore = true;
  }

  /// Sets loading state
  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  /// Ends loading state
  void endLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// Fetches the list of notifications for the user with pagination support
  Future<List<Notification>> fetchNotifications({
    required String userId,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) resetPagination();
    if (!_hasMore) return [];
    
    startLoading();
    try {
      final result = await _service.fetchNotificationsForUser(
        userId: userId,
        limit: limit,
        startAfterId: _lastDocId,
      );
      _lastDocId = result.lastDocId;
      final notifications = result.notifications;
      
      if (notifications.length < limit) _hasMore = false;
      
      if (refresh) {
        _notifications = notifications;
      } else {
        _notifications.addAll(notifications);
      }
      
      endLoading();
      return notifications;
    } catch (e) {
      endLoading();
      return [];
    }
  }

  /// Removes a notification from the list (called after deletion)
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }
}