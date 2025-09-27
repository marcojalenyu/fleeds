import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Clickable extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;

  const Clickable({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<Clickable> createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {
  double _opacity = 1.0;

  void _onEnter(PointerEnterEvent event) {
    setState(() {
      _opacity = 0.5;
    });
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _opacity = 1.0;
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