import 'package:fleeds/domain/models/user.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/features/screens/profile/logic/profile_controller.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/profile_btn.dart';
import 'package:fleeds/widgets/profile_pic.dart';
import 'package:fleeds/features/components/edit_profile/presentation/profile_edit_dialog.dart';

/// ProfileHeader displays the user's profile picture and a background banner.
class ProfileHeader extends StatelessWidget {
  
  final User user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(height: 120, color: Colors.grey[300]),
        Positioned(
          left: 16,
          bottom: -40,
          child: ProfilePic(user: user, size: 40.0),
        ),
      ],
    );
  }
}

/// ProfileButtonRow displays the "Edit Profile" button for the profile owner, or "Follow/Unfollow" for other users.
class ProfileButtonRow extends StatelessWidget {
  
  final ProfileController controller;
  const ProfileButtonRow({super.key, required this.controller});

  Future<void> _showProfileEditDialog(BuildContext context, User user) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(user: user),
    );
    if (result != null && result['bio'] != null) {
      controller.updateProfile(result['displayName'], result['bio']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        controller.isOwnProfile
            ? ProfileBtn(
                label: 'Edit Profile',
                onPressed: () => _showProfileEditDialog(context, controller.userOnProfile!),
              )
            : ProfileBtn(
                label: controller.isFollowing ? 'Unfollow' : 'Follow',
                isFollowing: controller.isFollowing,
                showHoverUnfollow: true,
                onPressed: () => controller.toggleFollowUser(controller.userOnProfile!.id),
              ),
        const SizedBox(width: 16),
      ],
    );
  }
}

/// ProfileStats displays the user's display name, username, bio, and follower/following counts.
class ProfileStats extends StatelessWidget {
  final User user;
  const ProfileStats({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            user.displayName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SelectableText(
            '@${user.username}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (user.bio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SelectableText(user.bio),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Clickable(
                onTap: () => goToUsersList(context, user.id, 'Followers'),
                child: Text('${user.followers.length} Followers'),
              ),
              const SizedBox(width: 16),
              Clickable(
                onTap: () => goToUsersList(context, user.id, 'Following'),
                child: Text('${user.following.length} Following'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}