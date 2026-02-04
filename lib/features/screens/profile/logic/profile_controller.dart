import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';

/// Controller for managing profile-related logic, including fetching user data, handling follow/unfollow actions, and updating profile information.
class ProfileController extends ChangeNotifier {
  final UserService _service;
  late User? userOnProfile;
  bool isFollowing = false;
  bool isOwnProfile = false;

  ProfileController({UserService? service})
      : _service = service ?? const UserService();

  static Future<ProfileController> initialize(String profileUserId, {UserService? service}) async {
    final controller = ProfileController(service: service);
    final userService = service ?? const UserService();
    controller.userOnProfile = (profileUserId.isEmpty) ? 
        AuthService.currentUser! : await userService.fetchUser(profileUserId);
    controller.isOwnProfile = AuthService.currentUser?.id == controller.userOnProfile?.id;
    controller.isFollowing = AuthService.currentUser != null &&
        controller.userOnProfile != null &&
        AuthService.currentUser!.following.contains(controller.userOnProfile!.id);
    return controller;
  }

  Future<void> toggleFollowUser(String userId) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || isOwnProfile) return;
    try {
      User updatedUser = currentUser.toggleFollow(userId);
      userOnProfile = userOnProfile!.addFollower(userId);
      AuthService.setCurrentUser(updatedUser);
      await _service.toggleFollow(updatedUser.id, userId);
      isFollowing = !isFollowing;
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<void> updateProfile(String newDisplayName, String newBio) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || !isOwnProfile) return;
    try {
      userOnProfile = userOnProfile!.updateDisplayName(newDisplayName).updateBio(newBio);
      AuthService.setCurrentUser(userOnProfile!);
      await _service.updateUserProfile(userOnProfile!.id, username: newDisplayName, bio: newBio);
      notifyListeners();
    } catch (e) {
      return;
    }    
  }
}


