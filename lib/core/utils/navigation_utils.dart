import 'package:fleeds/domain/models/post.dart';
import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/screens/userlist/presentation/userslist_screen.dart';

void goToPost(BuildContext context, {required Post post, required User user}) {
  Navigator.of(context).pushReplacementNamed(
    '/post/${post.id}',
    arguments: {'post': post, 'user': user},
  );
}

void goToPostById(BuildContext context, String postId) {
  Navigator.of(context).pushReplacementNamed('/post/$postId');
}

void goToProfile(BuildContext context, User user) {
  final isSelf = AuthService.currentUser?.id == user.id;
  if (isSelf) {
    Navigator.of(context).pushReplacementNamed('/profile');
  } else {
    Navigator.of(context).pushReplacementNamed('/user/${user.id}');
  }
}

void goToProfileById(BuildContext context, String userId) {
  final currentUserId = AuthService.currentUser?.id;
  if (currentUserId == userId) {
    Navigator.of(context).pushReplacementNamed('/profile');
  } else {
    Navigator.of(context).pushReplacementNamed('/user/$userId');
  }
}

void goToUsersList(BuildContext context, String userId, String type) {
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


