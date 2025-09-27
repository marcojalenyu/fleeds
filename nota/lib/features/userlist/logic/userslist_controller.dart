import 'package:flutter/material.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/data/services/user_service.dart';

class UsersListController extends ChangeNotifier {
  List<User> _users = [];
  String _label = '';

  List<User> get users => _users;
  String get label => _label;

  UsersListController(String userid, String label) {
    _label = label;
    print(1);
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