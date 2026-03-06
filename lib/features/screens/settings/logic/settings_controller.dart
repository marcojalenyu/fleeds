import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {

  final UserService _userService;
  final User currentUser;
  final String userId;

  SettingsController({String? userId}) :
    _userService = const UserService(),
    userId = userId ?? '',
    currentUser = AuthService.currentUser!; 

  void updateUsername(String newUsername) {
    // Implement logic to update the username
    // After updating, call notifyListeners() to update the UI
    notifyListeners();
  }

  void updatePassword(String newPassword) {
    // Implement logic to update the password
    // After updating, call notifyListeners() to update the UI
    notifyListeners();
  }
}