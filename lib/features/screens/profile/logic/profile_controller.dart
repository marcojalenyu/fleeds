import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/data/services/user_service.dart';
import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/components/post/logic/post_controller.dart';
import 'package:flutter/material.dart';

/// Controller for managing profile-related logic, including fetching user data, handling follow/unfollow actions, and updating profile information.
class ProfileController extends ChangeNotifier {
  
  final UserService _service;
  late User? userOnProfile;
  bool isFollowing = false;
  bool isOwnProfile = false;

  final PostController postController = PostController();
  final PostController repliesController = PostController();
  final PostController likedController = PostController();

  List<Post> userPosts = [];
  List<Post> userReplies = [];
  List<Post> likedPosts = [];

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

  Future<void> fetchUserContent(String userId) async {
    final posts = await postController.fetchPostsByUser(userId: userId, refresh: true);
    userPosts = posts.where((post) => !post.isReply).toList();
    userReplies = posts.where((post) => post.isReply).toList();
    likedPosts = await postController.fetchPostsLikedByUser(userId: userId, refresh: true);
    notifyListeners();
  }

   Future<List<Post>> loadMoreUserPosts() async {
    final posts = await postController.fetchPostsByUser(userId: userOnProfile!.id, refresh: false);
    final newPosts = posts.where((post) => !post.isReply).toList();
    userPosts.addAll(newPosts);
    notifyListeners();
    return newPosts;
  }

  Future<List<Post>> loadMoreUserReplies() async {
    final posts = await repliesController.fetchPostsByUser(userId: userOnProfile!.id, refresh: false);
    final newReplies = posts.where((post) => post.isReply).toList();
    userReplies.addAll(newReplies);
    notifyListeners();
    return newReplies;
  }

  Future<List<Post>> loadMoreLikedPosts() async {
    final posts = await likedController.fetchPostsLikedByUser(userId: userOnProfile!.id, refresh: false);
    likedPosts.addAll(posts);
    notifyListeners();
    return posts;
  }

  Future<void> toggleFollowUser(String userId) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || isOwnProfile) return;
    try {
      User updatedUser = currentUser.toggleFollow(userId);
      userOnProfile = userOnProfile!.addFollower(userId);
      AuthService.setCurrentUser(updatedUser);
      await _service.toggleFollow(updatedUser.id, updatedUser.username, userId);
      isFollowing = !isFollowing;
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<void> updateProfile(
    String newDisplayName, 
    String newBio, {
    String? avatarUrl,
    String? avatarColor,
    String? avatarBgColor,
    String? bannerUrl,
  }) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null || !isOwnProfile) return;
    try {
      userOnProfile = userOnProfile!.updateProfile(
        newDisplayName: newDisplayName, 
        newBio: newBio, 
        avatarUrl: avatarUrl,
        avatarColor: avatarColor,
        avatarBgColor: avatarBgColor,
        bannerUrl: bannerUrl,
      );
      AuthService.setCurrentUser(userOnProfile!);
      await _service.updateUserProfile(
        userOnProfile!.id, 
        displayName: newDisplayName, 
        bio: newBio,
        avatarUrl: avatarUrl,
        avatarColor: avatarColor,
        avatarBgColor: avatarBgColor,
        bannerUrl: bannerUrl,
      );
      notifyListeners();
    } catch (e) {
      return;
    }    
  }

  @override
  void dispose() {
    postController.dispose();
    repliesController.dispose();
    likedController.dispose();
    super.dispose();
  }
}


