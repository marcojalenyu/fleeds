import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nota/data/models/user.dart';

class AuthService {
  static User? _currentUser;
  static User? get currentUser => _currentUser;

  // Allows for updating the current user after login, signup, or profile changes
  static void setCurrentUser(User user) {
    _currentUser = user;
  }

  /// Allows for authentication checks across the app
  static Future<void> initializeCurrentUser() async {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      // Fetch user data from Firestore if needed
      final doc = await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(fbUser.uid, doc.data()!, email: fbUser.email ?? '');
      }
    }
  }

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

      _currentUser = User.fromFirestore(
        credential.user!.uid, 
        userData, 
        email: email
      );

    } catch (e) {
      return false;
    }

    return true;
  }

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
        'followers': [],
        'following': [],
        'likedPosts': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentUser = User(
        id: credential.user!.uid,
        username: username,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      return true;

    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    await fb.FirebaseAuth.instance.signOut();
    _currentUser = null;
  }
}