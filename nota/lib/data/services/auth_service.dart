import 'package:nota/data/mock/mock_users.dart';
import 'package:nota/data/models/user.dart';

class AuthService {

  static User? _currentUser;
  static User? get currentUser => _currentUser;

  static bool login(String username, String password) {
    try {
      final user = mockUsers.firstWhere((user) => user.username == username && user.password == password);
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool signup(String username, String password, String displayName) {
    if (mockUsers.any((user) => user.username == username)) {
      return false; // Username already exists
    }
    final newUser = User(
      id: 'user${mockUsers.length + 1}',
      username: username,
      password: password,
      displayName: displayName,
    );
    mockUsers.add(newUser);
    _currentUser = newUser;
    return true;
  }

  static void logout() {
    _currentUser = null;
  }
}