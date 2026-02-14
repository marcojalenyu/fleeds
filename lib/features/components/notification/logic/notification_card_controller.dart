import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/data/services/notification_service.dart';
import 'package:fleeds/domain/models/notification.dart';
import 'package:flutter/material.dart' hide Notification;

class NotificationCardController extends ChangeNotifier {
  
  final Notification notification;
  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  NotificationCardController({required this.notification});

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