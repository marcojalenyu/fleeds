import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/data/services/user_service.dart';

/// Controller for managing the state of the users list screen, fetching followers or following users based on the provided label
class UsersListController extends ChangeNotifier {
  
  List<User> _users = [];
  String _label = '';
  bool _isLoading = false;

  List<User> get users => _users;
  String get label => _label;
  bool get isLoading => _isLoading;
  
  UsersListController(String userid, String label) {
    _label = label;
    _fetchUsers(userid);
  }

  /// Fetches the list of users based on the label (followers or following) and updates the state accordingly
  Future<void> _fetchUsers(String userid) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_label == 'Followers') {
        _users = await UserService().fetchFollowers(userid);
      } else if (_label == 'Following') {
        _users = await UserService().fetchFollowing(userid);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(String userid) async {
    await _fetchUsers(userid);
  }
}


