import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/models/user.dart';

class UserService {
  static Future<User?> getUserById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (doc.exists) {
        return User.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<User>> getFollowers(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) return [];
      final data = doc.data()!;
      final List<String> followerIds = List<String>.from(data['followers'] ?? []);
      if (followerIds.isEmpty) return [];

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: followerIds)
          .get();

      return query.docs.map((doc) => User.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<User>> getFollowing(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) return [];
      final data = doc.data()!;
      final List<String> followingIds = List<String>.from(data['following'] ?? []);
      if (followingIds.isEmpty) return [];

      final query = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: followingIds)
          .get();

      return query.docs.map((doc) => User.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateDisplayName(String userId, String newName) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      await docRef.update({'displayName': newName, 'updatedAt': FieldValue.serverTimestamp()});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateBio(String userId, String newBio) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      await docRef.update({'bio': newBio, 'updatedAt': FieldValue.serverTimestamp()});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> likePost(String userId, List<String> likedPosts) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      await docRef.update({'likedPosts': likedPosts, 'updatedAt': FieldValue.serverTimestamp()});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> follow(String currentUserId, String targetUserId) async {
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final targetUserRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);

    try {
      // Update current user's following
      await currentUserRef.update({
        'following': FieldValue.arrayUnion([targetUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update target user's followers
      await targetUserRef.update({
        'followers': FieldValue.arrayUnion([currentUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> unfollow(String currentUserId, String targetUserId) async {
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final targetUserRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);

    try {
      // Remove from current user's following
      await currentUserRef.update({
        'following': FieldValue.arrayRemove([targetUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Remove from target user's followers
      await targetUserRef.update({
        'followers': FieldValue.arrayRemove([currentUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}

