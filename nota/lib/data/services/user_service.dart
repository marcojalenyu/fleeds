import 'package:nota/data/mock/mock_users.dart';
import 'package:nota/data/models/user.dart';

class UserService {
  static User? getUserById(String id) {
    try {
      return mockUsers.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static void updateDisplayName(String userId, String newName) {
    final user = getUserById(userId);
    if (user != null) {
      user.updateDisplayName(newName);
    }
  }

  static void updateBio(String userId, String newBio) {
    final user = getUserById(userId);
    if (user != null) {
      user.updateBio(newBio);
    }
  }

  static void likePost(String userId, String postId, bool liked) {
    final user = getUserById(userId);
    if (user != null) {
      if (liked) {
        user.likePost(postId);
      } else {
        user.unlikePost(postId);
      }
    }
  }

  static void followUser(String userId, String targetUserId, bool follow) {
    final user = getUserById(userId);
    final targetUser = getUserById(targetUserId);
    if (user != null && targetUser != null) {
      if (follow) {
        user.followUser(targetUserId);
        targetUser.followers.add(userId);
      } else {
        user.unfollowUser(targetUserId);
        targetUser.removeFollower(userId);
      }
    }
  }

  static Future<List<User>> getFollowers(String userId) async {
    final user = getUserById(userId);
    return user?.followers.map((followerId) => getUserById(followerId)).whereType<User>().toList() ?? [];
  }

  static Future<List<User>> getFollowing(String userId) async {
    final user = getUserById(userId);
    return user?.following.map((followingId) => getUserById(followingId)).whereType<User>().toList() ?? [];
  }
}