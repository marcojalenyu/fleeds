import 'package:fleeds/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/domain/models/user.dart';

/// Controller for managing follow/unfollow state for a user card
class UserCardController extends ChangeNotifier {
  
  final String _userId;
  final User? _currentUser;
  
  bool _isFollowing = false;
  bool _isLoading = false;

  bool get isFollowing => _isFollowing;
  bool get isLoading => _isLoading;
  bool get isCurrentUser => _currentUser?.id == _userId;

  UserCardController(this._userId) 
      : _currentUser = AuthService.currentUser {
    if (!isCurrentUser && _currentUser != null) {
      _checkFollowStatus();
    }
  }

  /// Checks if the current user is following the user
  Future<void> _checkFollowStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isFollowing = _currentUser?.isFollowingUser(_userId) ?? false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles follow/unfollow status for the user
  Future<void> toggleFollow() async {
    if (isCurrentUser || _currentUser == null) return;
    final wasFollowing = _isFollowing;
    _isFollowing = !_isFollowing;
    _isLoading = true;
    notifyListeners();
    try {
      final updatedFollowing = await UserService().toggleFollow(_currentUser.id, _userId);
      if (updatedFollowing != null) {
        AuthService.setCurrentUser(_currentUser.copyWith(following: updatedFollowing));
      } else {
        _isFollowing = wasFollowing;
      }
    } catch (e) {
      _isFollowing = wasFollowing;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}