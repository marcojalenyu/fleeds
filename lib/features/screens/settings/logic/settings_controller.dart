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

  Future<String> updatePassword(String currentPassword, String newPassword) async {
    if (!AuthService.isAuthenticated()) return '';
    try {
      if (!await AuthService.reauthenticate(currentPassword)) {
        return 'Incorrect password. Please try again.';
      } else {
        final result = await AuthService.updatePassword(currentPassword, newPassword);
        if (result) {
          return 'Password updated successfully.';
        } else {
          return 'Failed to update password. Please try again.';
        }
      }
    } catch (e) {
      return 'An error occurred while updating the password. Please try again.';
    }
  }
}