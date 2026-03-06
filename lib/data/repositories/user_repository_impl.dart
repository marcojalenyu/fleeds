import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/dtos/user_dto.dart';
import 'package:fleeds/domain/repositories/user_repository.dart';

/// Implementation of UserRepository that interacts with Firestore to fetch and manipulate user data.
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl();

  @override
  Future<UserDTO?> fetchUser(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserDTO.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<UserDTO>?> fetchFollowers(String userId) async {
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

      return query.docs.map((doc) => UserDTO.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<UserDTO>?> fetchFollowing(String userId) async {
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

      return query.docs.map((doc) => UserDTO.fromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<UserDTO?> updateUsername(String userId, String newUsername) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      // Check if the new username is already taken by another user
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .where(FieldPath.documentId, isNotEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Username is already taken
        return null;
      }

      await docRef.update({
        'username': newUsername,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDoc = await docRef.get();
      if (!updatedDoc.exists) return null;
      return UserDTO.fromFirestore(updatedDoc.id, updatedDoc.data()!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserDTO?> updateUserProfile(
    String userId, 
    {String? displayName, String? bio, String? avatarUrl, String? avatarColor, String? avatarBgColor, String? bannerUrl}
  ) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    try {
      final updates = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (avatarColor != null) updates['avatarColor'] = avatarColor;
      if (avatarBgColor != null) updates['avatarBgColor'] = avatarBgColor;
      if (bannerUrl != null) updates['bannerUrl'] = bannerUrl;

      await docRef.update(updates);

      final updatedDoc = await docRef.get();
      if (!updatedDoc.exists) return null;
      return UserDTO.fromFirestore(updatedDoc.id, updatedDoc.data()!);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>?> toggleFollow(String currentUserId, String targetUserId) async {
    final currentRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
    final targetRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);

    try {
      return FirebaseFirestore.instance.runTransaction((tx) async {
        final currentSnap = await tx.get(currentRef);
        final targetSnap = await tx.get(targetRef);
        if (!currentSnap.exists || !targetSnap.exists) return null;

        final currentData = currentSnap.data()!;
        final List<String> following = List<String>.from(currentData['following'] ?? []);
        final bool alreadyFollowing = following.contains(targetUserId);

        if (alreadyFollowing) {
          tx.update(currentRef, {
            'following': FieldValue.arrayRemove([targetUserId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          tx.update(targetRef, {
            'followers': FieldValue.arrayRemove([currentUserId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return following.where((id) => id != targetUserId).toList();
        } else {
          tx.update(currentRef, {
            'following': FieldValue.arrayUnion([targetUserId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          tx.update(targetRef, {
            'followers': FieldValue.arrayUnion([currentUserId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return [...following, targetUserId];
        }
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>?> removeFollower(String userId, String followerId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final followerRef = FirebaseFirestore.instance.collection('users').doc(followerId);

    try {
      return FirebaseFirestore.instance.runTransaction((tx) async {
        final userSnap = await tx.get(userRef);
        final followerSnap = await tx.get(followerRef);
        if (!userSnap.exists || !followerSnap.exists) return null;

        final userData = userSnap.data()!;
        final List<String> followers = List<String>.from(userData['followers'] ?? []);

        tx.update(userRef, {
          'followers': FieldValue.arrayRemove([followerId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        tx.update(followerRef, {
          'following': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return followers.where((id) => id != followerId).toList();
      });
    } catch (e) {
      return null;
    }
  }
}