import 'package:fleeds/core/utils/date_utils.dart';
import 'package:fleeds/data/services/auth_service.dart';
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
  final double bannerHeight;
  final double profilePicSize;
  final VoidCallback? onAvatarEdit;
  final VoidCallback? onBannerEdit;
  
  const ProfileHeader({
    super.key, 
    required this.user, 
    this.bannerHeight = 120.0, 
    this.profilePicSize = 40.0,
    this.onAvatarEdit,
    this.onBannerEdit
  });

  bool get canEdit => onAvatarEdit != null || onBannerEdit != null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildBanner(),
        Positioned(
          left: 16,
          bottom: -profilePicSize,
          child: _buildProfilePic(),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    final banner = Stack(
      children: [
        Container(
          height: bannerHeight,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            image: user.bannerUrl.isNotEmpty
                ? DecorationImage(
                    image: AssetImage(user.bannerUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
      ],
    );

    if (onBannerEdit != null) {
      return Clickable(
        onTap: onBannerEdit,
        child: banner,
      );
    }
    return banner;
  }

  Widget _buildProfilePic() {
    final profilePic = Stack(
      children: [
        ProfilePic(
          user: user,
          size: profilePicSize,
        ),
      ],
    );
    
    if (onAvatarEdit != null) {
      return Clickable(
        onTap: onAvatarEdit,
        child: profilePic,
      );
    }
    return profilePic;
  }
}

/// ProfileButtonRow displays the "Edit Profile" button for the profile owner, or "Follow/Unfollow" for other users.
class ProfileButtonRow extends StatelessWidget {
  
  final ProfileController controller;
  const ProfileButtonRow({super.key, required this.controller});

  Future<void> _showProfileEditDialog(BuildContext context, User user) async {
    if (!await AuthService.requireAuth(context)) return;
    if (!context.mounted) return;
    final result = await showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(user: user),
    );
    if (result != null) {
      controller.updateProfile(
        result['displayName'], 
        result['bio'],
        avatarUrl: result['avatarUrl'],
        avatarColor: result['avatarColor'],
        avatarBgColor: result['avatarBgColor'],
        bannerUrl: result['bannerUrl'],
      );
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
                onPressed: () async {
                  if (!await AuthService.requireAuth(context)) return;
                  controller.toggleFollowUser(controller.userOnProfile!.id);
                },
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
              Icon(Icons.calendar_month, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              SelectableText(
                'Joined ${DisplayDateUtils.displayMonthYear(user.createdAt)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Clickable(
                onTap: () => NavigationUtils.goToUsersList(context, user.id, 'Followers'),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${user.followers.length}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' Followers'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Clickable(
                onTap: () => NavigationUtils.goToUsersList(context, user.id, 'Following'),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${user.following.length}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' Following'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}