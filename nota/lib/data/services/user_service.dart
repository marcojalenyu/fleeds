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
}