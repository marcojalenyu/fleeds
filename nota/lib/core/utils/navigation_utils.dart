import 'package:flutter/material.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/auth_service.dart';

void goToProfile(BuildContext context, User user) {
  final isSelf = AuthService.currentUser?.id == user.id;
  if (isSelf) {
    Navigator.of(context).pushNamed('/profile');
  } else {
    Navigator.of(context).pushNamed('/profile/${user.id}');
  }
}