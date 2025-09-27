import 'package:flutter/material.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/data/services/user_service.dart';

class ProfileController extends ChangeNotifier {
  late User user;
  bool isFollowing = false;
  bool isOwnProfile = false;

  ProfileController(String profileUserId) {
    if (profileUserId.isEmpty) {
      user = AuthService.currentUser!;
    } else {
      user = UserService.getUserById(profileUserId)!;
    }
    isOwnProfile = AuthService.currentUser?.id == user.id;
    isFollowing = AuthService.currentUser?.following.contains(user.id) ?? false;
  }

  void followUser() {
    if (AuthService.currentUser == null) return;
    UserService.followUser(AuthService.currentUser!.id, user.id, !isFollowing);
    isFollowing = !isFollowing;
    notifyListeners();
  }

  void updateBio(String newBio) {
    if (AuthService.currentUser == null || !isOwnProfile) return;
    UserService.updateBio(user.id, newBio);
    user.updateBio(newBio);
    notifyListeners();
  }
}