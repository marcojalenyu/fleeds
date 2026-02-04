import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/widgets/clickable.dart';

/// A clickable version that navigates to the user's profile on tap.
class ClickableProfilePic extends ProfilePic {
  const ClickableProfilePic({
    super.key,
    required super.imageUrl,
    super.size,
    super.onTap,
    super.user,
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
  
  final String _imageUrl;
  final double _size;
  final VoidCallback? onTap;
  final dynamic user;

  const ProfilePic({
    super.key,
    String imageUrl = '',
    double size = defaultSize,
    this.onTap,
    this.user,
  }) : _size = size, _imageUrl = imageUrl;

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
      padding: const EdgeInsets.only(top: 4, right: 12),
      child: CircleAvatar(
        radius: _size,
        backgroundColor: Colors.grey,
        child: _imageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                _imageUrl,
                width: _size,
                height: _size,
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


