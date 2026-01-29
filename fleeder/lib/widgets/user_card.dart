import 'package:flutter/material.dart';
import 'package:fleeds/core/utils/navigation_utils.dart';
import 'package:fleeds/data/models/user.dart';
import 'package:fleeds/widgets/card.dart';
import 'package:fleeds/widgets/clickable.dart';
import 'package:fleeds/widgets/profile_pic.dart';

class UserCard extends StatefulWidget {
  final User user;
  final void Function()? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClickableProfilePic(imageUrl: '', user: widget.user),
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
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          widget.user.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

