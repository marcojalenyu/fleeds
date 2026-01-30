import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/widgets/clickable.dart'; // Import the new widget

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

class ProfilePic extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;
  final dynamic user;

  const ProfilePic({
    super.key,
    this.imageUrl = '',
    this.size = 24.0,
    this.onTap,
    this.user,
  });

  Widget _buildProfilePicture() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 12),
      child: CircleAvatar(
        radius: size,
        backgroundColor: Colors.grey,
        child: imageUrl.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person, color: Colors.white, size: 25);
                  },
                ),
              )
            : Icon(Icons.person, color: Colors.white, size: size),
      ),
    );
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
}


