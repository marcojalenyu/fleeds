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
}