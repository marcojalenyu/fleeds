import 'package:fleeds/domain/models/user.dart';
import 'package:fleeds/features/components/user/logic/user_card_controller.dart';
import 'package:fleeds/widgets/profile_btn.dart';
import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/widgets/card.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/profile_pic.dart';

/// Widget to display a user's information in a card format, used in followers/following lists
class UserCard extends StatefulWidget {
  
  final User user;

  const UserCard({
    super.key,
    required this.user,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

/// Includes follow/unfollow button logic and state management for the user card
class _UserCardState extends State<UserCard> {

  late final UserCardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserCardController(widget.user.id);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClickableProfilePic(user: widget.user),
            const SizedBox(width: 0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Clickable(
                    child: Text(widget.user.displayName, style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => goToProfile(context, widget.user),
                  ),
                  Clickable(
                    child: Text('@${widget.user.username}', style: TextStyle(color: Colors.grey[600])),
                    onTap: () => goToProfile(context, widget.user),
                  ),
                  widget.user.bio.isNotEmpty
                      ? Text(
                            widget.user.bio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            if (!_controller.isCurrentUser)
              Center(
                child: ProfileBtn(
                  label: _controller.isFollowing ? 'Unfollow' : 'Follow',
                  isFollowing: _controller.isFollowing,
                  showHoverUnfollow: true,
                  onPressed: () => _controller.toggleFollow(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}