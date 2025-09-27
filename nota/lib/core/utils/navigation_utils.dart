import 'package:flutter/material.dart';
import 'package:nota/data/models/user.dart';

void goToProfile(BuildContext context, User user) {
  Navigator.of(context).pushNamed('/profile', arguments: user);
}