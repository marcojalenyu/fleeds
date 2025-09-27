import 'package:flutter/material.dart';
import 'package:nota/data/models/user.dart';
import 'package:nota/widgets/card.dart';
import 'package:nota/widgets/profile_pic.dart';

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
        children: [
          ClickableProfilePic(imageUrl: '', user: widget.user),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.displayName, style: TextStyle(fontWeight: FontWeight.bold)),
                Text('@${widget.user.username}'),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: widget.onTap,
          ),
        ],
      ),
    );
  }
}