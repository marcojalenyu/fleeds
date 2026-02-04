import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/domain/models/user.dart';

/// Service layer that handles authentication logic, user session management, and interaction with Firebase Auth.
class AuthService {
  static User? _currentUser;
  static User? get currentUser => _currentUser;
  static const UserService _userService = UserService();

  const AuthService();

  /// Updates the current user in the AuthService
  static void setCurrentUser(User? user) {
    _currentUser = user;
  }

  /// Allows for authentication checks across the app
  static Future<void> initializeCurrentUser() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      _currentUser = await _userService.fetchUser(fbUser.uid);
    }
  }

  /// Logs in a user with the provided username and password.
  static Future<bool> login(String username, String password) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) return false;

      final userData = query.docs.first.data();
      final email = userData['email'] as String?;

      if (email == null) return false;

      final credential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = await _userService.fetchUser(credential.user!.uid);
      return _currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Signs up a new user with the provided details.
  static Future<bool> signup(
    String displayName,
    String username,
    String email,
    String password,
  ) async {
    try {
      // Check if username already exists
      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) return false;

      // Create user in Firebase Auth
      final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'username': username,
        'displayName': displayName,
        'email': email,
        'bio': '',
        'avatarUrl': '',
        'followers': [],
        'following': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentUser = await _userService.fetchUser(credential.user!.uid);

      return _currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Logs out the current user.
  static Future<void> logout() async {
    await fb.FirebaseAuth.instance.signOut();
    _currentUser = null;
  }
}