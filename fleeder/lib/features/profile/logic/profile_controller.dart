import 'package:flutter/material.dart';
import 'package:fleeder/data/models/user.dart';
import 'package:fleeder/data/services/auth_service.dart';
import 'package:fleeder/data/services/user_service.dart';

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

  Future<void> toggleFollowUser(String userId) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || isOwnProfile) return;

    bool alreadyFollowing = currentUser.following.contains(userId);

    User updatedUser;
    if (alreadyFollowing) {
      // Unfollow logic
      updatedUser = currentUser.unfollow(userId);
      AuthService.setCurrentUser(updatedUser);
      await UserService.unfollow(updatedUser.id, userId);

      // Update viewed user's followers list locally
      user = user.copyWith(
        followers: user.followers.where((id) => id != currentUser.id).toList(),
        updatedAt: DateTime.now(),
      );
    } else {
      // Follow logic
      updatedUser = currentUser.follow(userId);
      AuthService.setCurrentUser(updatedUser);
      await UserService.follow(updatedUser.id, userId);

      // Update viewed user's followers list locally
      user = user.copyWith(
        followers: [...user.followers, currentUser.id],
        updatedAt: DateTime.now(),
      );
    }

    isFollowing = updatedUser.following.contains(userId);
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
