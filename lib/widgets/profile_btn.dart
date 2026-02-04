import 'package:flutter/material.dart';

/// A profile button that changes appearance based on follow state and hover.
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

/// State class for ProfileBtn widget.
class _ProfileBtnState extends State<ProfileBtn> {
  
  bool _isHovering = false;
  bool get _shouldShowHover => widget.isFollowing && widget.showHoverUnfollow;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _shouldShowHover ? setState(() => _isHovering = true) : null,
      onExit: (_) => _shouldShowHover ? setState(() => _isHovering = false) : null,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: _shouldShowHover && _isHovering
          ? ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
          ) : null,
        child: Text(_getButtonLabel()),
      ),
    );
  }

  /// Determines the button label based on hover state.
  String _getButtonLabel() {
    if (_shouldShowHover) {
      return _isHovering ? 'Unfollow' : 'Followed';
    }
    return widget.label;
  }
}


