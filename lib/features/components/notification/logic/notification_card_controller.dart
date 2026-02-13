import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/data/services/notification_service.dart';
import 'package:fleeds/domain/models/notification.dart';
import 'package:flutter/material.dart' hide Notification;

class NotificationCardController extends ChangeNotifier {
  
  final Notification notification;

  bool _isDeleting = false;
  bool _isMarkingAsRead = false;

  bool get isDeleting => _isDeleting;
  bool get isMarkingAsRead => _isMarkingAsRead;
  bool get isLoading => _isDeleting || _isMarkingAsRead;

  NotificationCardController({required this.notification});

  /// Marks the notification as read
  Future<void> markAsRead() async {
    if (AuthService.currentUser == null) return;
    if (notification.read || _isMarkingAsRead) return;
    _isMarkingAsRead = true;
    notifyListeners();    
    try {
      await NotificationService().markNotificationAsRead(notification.id);
    } catch (e) {
      // Silently fail - marking as read is not critical
    } finally {
      _isMarkingAsRead = false;
      notifyListeners();
    }
  }

  /// Deletes the notification
  Future<bool> deleteNotification() async {
    if (AuthService.currentUser == null) return false;
    if (_isDeleting) return false;
    _isDeleting = true;
    notifyListeners();
    try {
      await NotificationService().deleteNotification(notification.id);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
}