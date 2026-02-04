import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A clickable widget that changes opacity on hover and handles tap events.
class Clickable extends StatefulWidget {
  
  final VoidCallback? onTap;
  final Widget child;
  final bool _opaqueWhenHovered;

  const Clickable({
    super.key,
    required this.child,
    this.onTap,
    bool opaqueWhenHovered = true,
  }) : _opaqueWhenHovered = opaqueWhenHovered;

  @override
  State<Clickable> createState() => _ClickableState();
}

/// State class for Clickable widget.
class _ClickableState extends State<Clickable> {
  
  static const double hoveredOpacity = 0.5;
  static const double normalOpacity = 1.0;
  
  double _opacity = normalOpacity;

  void _onEnter(PointerEnterEvent event) {
    setState(() {
      _opacity = widget._opaqueWhenHovered ? 
        hoveredOpacity : normalOpacity;
    });
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _opacity = normalOpacity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: _opacity,
          child: widget.child,
        ),
      ),
    );
  }
}


