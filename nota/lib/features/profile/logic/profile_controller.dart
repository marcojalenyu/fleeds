import 'package:flutter/material.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/data/services/user_service.dart';

class ProfileController extends ChangeNotifier {
  late User user;
  bool isFollowing = false;
  bool isOwnProfile = false;

  ProfileController._();

  static Future<ProfileController> create(String profileUserId) async {
    final controller = ProfileController._();
    if (profileUserId.isEmpty) {
      controller.user = AuthService.currentUser!;
    } else {
      controller.user = (await UserService.getUserById(profileUserId))!;
    }
    controller.isOwnProfile = AuthService.currentUser?.id == controller.user.id;
    controller.isFollowing = AuthService.currentUser?.following.contains(controller.user.id) ?? false;
    return controller;
  }

  Future<void> followUser(String userId) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || isOwnProfile) return;
    
    user = currentUser.follow(userId);
    AuthService.setCurrentUser(user);

    await UserService.followUser(user.id, user.following);
    isFollowing = user.following.contains(userId);
    notifyListeners();
  }

  Future<void> updateProfile(String newDisplayName, String newBio) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || !isOwnProfile) return;

    user = user.updateDisplayName(newDisplayName).updateBio(newBio);
    AuthService.setCurrentUser(user);

    await UserService.updateDisplayName(user.id, newDisplayName);
    await UserService.updateBio(user.id, newBio);
    notifyListeners();
  }
}