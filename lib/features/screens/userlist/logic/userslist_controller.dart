import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/data/services/user_service.dart';

class UsersListController extends ChangeNotifier {
  List<User> _users = [];
  String _label = '';

  List<User> get users => _users;
  String get label => _label;

  UsersListController(String userid, String label) {
    _label = label;
    if (label == 'Followers') {
      UserService().fetchFollowers(userid).then((fetchedUsers) {
        _users = fetchedUsers;
        notifyListeners();
      });
    } else if (label == 'Following') {
      UserService().fetchFollowing(userid).then((fetchedUsers) {
        _users = fetchedUsers;
        notifyListeners();
      });
    }
  }
}


