import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {

  final UserService _userService;
  final String userId;

  User get currentUser => AuthService.currentUser!;

  SettingsController() :
    _userService = const UserService(),
    userId = AuthService.currentUser?.id ?? '';

  Future<String> updateUsername(String newUsername, String currentPassword) async {
    if (!AuthService.isAuthenticated()) return '';
    try {
      if (!await AuthService.reauthenticate(currentPassword)) {
        notifyListeners();
        return 'Incorrect password. Please try again.';
      } else {
        final updatedUser = currentUser.updateUsername(newUsername);
        final result = await _userService.updateUsername(userId, newUsername);
        if (result == null) return 'Username already exists.';
        AuthService.setCurrentUser(updatedUser);
        notifyListeners();
        return 'Username updated successfully.';
      }
    } catch (e) {
      return 'An error occurred while updating the username. Please try again.';
    }
  }

  void updatePassword(String newPassword) {
    // Implement logic to update the password
    // After updating, call notifyListeners() to update the UI
    notifyListeners();
  }
}