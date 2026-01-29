import 'package:flutter/material.dart';

class ProfileBtn extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isFollowing;
  final bool showHoverUnfollow;

  const ProfileBtn({
    super.key,
    required this.label,
    required this.onPressed,
    this.isFollowing = false,
    this.showHoverUnfollow = false,
  });

  @override
  State<ProfileBtn> createState() => _ProfileBtnState();
}

class _ProfileBtnState extends State<ProfileBtn> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final showHover = widget.isFollowing && widget.showHoverUnfollow;
    return MouseRegion(
      onEnter: (_) {
        if (showHover) setState(() => _isHovering = true);
      },
      onExit: (_) {
        if (showHover) setState(() => _isHovering = false);
      },
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: (widget.isFollowing && widget.showHoverUnfollow && _isHovering)
          ? ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            )
          : null,
        child: Text(
          showHover
              ? (_isHovering ? 'Unfollow' : 'Followed')
              : widget.label,
        ),
      ),
    );
  }
}

