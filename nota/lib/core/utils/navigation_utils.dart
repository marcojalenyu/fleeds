import 'package:flutter/material.dart';
import 'package:nota/data/models/post.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/features/userlist/presentation/userslist_screen.dart';

void goToPost(BuildContext context, {required Post post, required User user}) {
  Navigator.of(context).pushNamed(
    '/post/${post.id}',
    arguments: {'post': post, 'user': user},
  );
}

void goToProfile(BuildContext context, User user) {
  final isSelf = AuthService.currentUser?.id == user.id;
  if (isSelf) {
    Navigator.of(context).pushNamed('/profile');
  } else {
    Navigator.of(context).pushNamed('/profile/${user.id}');
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