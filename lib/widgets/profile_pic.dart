import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/widgets/clickable.dart';

/// A clickable version that navigates to the user's profile on tap.
class ClickableProfilePic extends ProfilePic {
  const ClickableProfilePic({
    super.key,
    super.size,
    super.onTap,
    super.noPadding,
    required super.user,
  });

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: onTap ?? () => goToProfile(context, user),
      child: super.build(context),
    );
  }
}

/// A widget that displays a user's profile picture.
class ProfilePic extends StatelessWidget {

  static const double defaultSize = 24.0;
  
  final double _size;
  final VoidCallback? onTap;
  final User user;
  final bool noPadding;

  const ProfilePic({
    super.key,
    double size = defaultSize,
    this.onTap,
    this.noPadding = false,
    required this.user,
  }) : _size = size;

  bool get _isDefault => user.avatarUrl.isEmpty;
  String get _imageUrl => user.avatarUrl;
  String get _avatarColor => user.avatarColor;
  String get _avatarBgColor => user.avatarBgColor;

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return onTap != null
        ? Clickable(
            onTap: onTap ?? () => goToProfile(context, user),
            child: _buildProfilePicture(),
          )
        : _buildProfilePicture();
  }

  Widget _buildProfilePicture() {
    return Padding(
      padding: noPadding ? EdgeInsets.zero : const EdgeInsets.only(top: 4, right: 12),
      child: CircleAvatar(
        radius: _size,
        backgroundColor: _isDefault ? Colors.grey : _parseColor(_avatarBgColor),
        child: !_isDefault
          ? ClipOval(
              child: Image.asset(
                _imageUrl,
                color: _parseColor(_avatarColor),
                width: _size*1.5,
                height: _size*1.5,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, color: Colors.white, size: _size);
                },
              ),
            )
          : Icon(Icons.person, color: Colors.white, size: _size),
      ),
    );
  } 
}


