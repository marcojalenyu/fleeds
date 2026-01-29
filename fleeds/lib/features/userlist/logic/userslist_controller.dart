import 'package:flutter/material.dart';
import 'package:fleeds/data/models/user.dart';
import 'package:fleeds/data/services/user_service.dart';

class UsersListController extends ChangeNotifier {
  List<User> _users = [];
  String _label = '';

  List<User> get users => _users;
  String get label => _label;

  UsersListController(String userid, String label) {
    _label = label;
    if (label == 'Followers') {
      UserService.getFollowers(userid).then((fetchedUsers) {
        _users = fetchedUsers;
        notifyListeners();
      });
    } else if (label == 'Following') {
      UserService.getFollowing(userid).then((fetchedUsers) {
        _users = fetchedUsers;
        notifyListeners();
      });
    }
  }
}


