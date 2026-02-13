import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/dtos/notification_dto.dart';
import 'package:fleeds/domain/repositories/notification_repository.dart';

/// Implementation of NotificationRepository that interacts with Firestore to fetch and manipulate notification data.
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl();

  @override
  Future<({List<NotificationDTO> notifications, String? lastDocId})> fetchNotificationsForUser({
    required String userId,
    int limit = 20,
    String? startAfterId,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('targetUserId', isEqualTo: userId)
        .where('deleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);
      
      if (startAfterId != null) {
        final lastDoc = await FirebaseFirestore.instance.collection('notifications').doc(startAfterId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }
      
      final snapshot = await query.get();
      
      List<NotificationDTO> notifications = snapshot.docs
          .map((doc) => NotificationDTO.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      String? lastDocId = snapshot.docs.isNotEmpty ? snapshot.docs.last.id : null;
      
      return (notifications: notifications, lastDocId: lastDocId);
    } catch (e) {
      return (notifications: <NotificationDTO>[], lastDocId: null);
    }
  }

  @override
  Future<String?> addNotification({
    required String type,
    required String targetUserId,
    required String triggeredByUsername,
    required String triggeredByUserId,
    String? relatedPostId,
  }) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('notifications').add({
        'type': type,
        'targetUserId': targetUserId,
        'triggeredByUsername': triggeredByUsername,
        'triggeredByUserId': triggeredByUserId,
        'relatedPostId': relatedPostId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'deleted': false,
      });
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).update({
        'deleted': true,
      });
    } catch (e) {
      // Handle error if needed
    }
  }
}