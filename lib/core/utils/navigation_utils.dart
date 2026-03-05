import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/screens/search/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/screens/userlist/presentation/userslist_screen.dart';

/// Utility class for handling navigation across the app, ensuring consistent routing and argument passing.
class NavigationUtils {

  /// Navigate to a route based on the tapped index in the bottom navigation bar,
  static Future<void> goToByIndex(BuildContext context, int index, bool isMobile) async {
    switch (index) {
      case 0:
        goToHome(context);
        break;
      case 1:
        goToProfile(context, AuthService.currentUser);
        break;
      case 2:
        if (isMobile) {
          goToSearch(context);
        } else {
          goToNotifications(context);
        }
        break;
      case 3:
        if (isMobile) {
          goToNotifications(context);
        } else {
          goToSettings(context);
        }
        break;
      case 4:
        if (isMobile) {
          goToSettings(context);
        } else {
          await AuthService.logout();
          if (context.mounted) {
            goToLogin(context);
          }
        }
        break;
      case 5:
        if (isMobile) {
          await AuthService.logout();
          if (context.mounted) {
            goToLogin(context);
          }
        }
        break;
    }
  }

  static void goToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  static void goToHome(BuildContext context) {
    Navigator.of(context).pushNamed('/');
  }

  static void goToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchScreen()),
    );
  }

  static void goToPost(BuildContext context, {required Post post, required User user}) {
    Navigator.of(context).pushNamed(
      '/post/${post.id}',
      arguments: {'post': post, 'user': user},
    );
  }

  static void goToPostById(BuildContext context, String postId) {
    Navigator.of(context).pushNamed('/post/$postId');
  }

  static void goToProfile(BuildContext context, User? user) {
    final isSelf = AuthService.currentUser?.id == user?.id;
    if (isSelf) {
      Navigator.of(context).pushNamed('/profile', arguments: user);
    } else {
      Navigator.of(context).pushNamed('/user/${user?.id}');
    }
  }

  static void goToProfileById(BuildContext context, String userId) {
    final currentUserId = AuthService.currentUser?.id;
    if (currentUserId == userId) {
      Navigator.of(context).pushNamed('/profile', arguments: AuthService.currentUser);
    } else {
      Navigator.of(context).pushNamed('/user/$userId');
    }
  }

  static void goToUsersList(BuildContext context, String userId, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsersListScreen(
          userId: userId,
          type: type,
        ),
      ),
    );
  }

  static void goToNotifications(BuildContext context) {
    Navigator.of(context).pushNamed('/notifications');
  }

  static void goToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }
}