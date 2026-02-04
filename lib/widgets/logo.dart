import 'package:flutter/material.dart';

/// Clickable version of the Logo widget that navigates to home on tap.
class ClickableLogo extends Logo {
  const ClickableLogo({
    super.key, 
    super.size, 
    super.color,
  }) : super(isButton: true);
}

/// A widget that displays the app logo.
class Logo extends StatelessWidget {
  
  static const double defaultSize = 64.0;

  final double _size;
  final Color? _color;
  final bool _isButton;

  const Logo(
    {
      super.key, 
      double size = defaultSize, 
      Color? color,
      bool isButton = false
    }
  ) : _isButton = isButton, _color = color, _size = size;

  @override
  Widget build(BuildContext context) {
    if (_isButton) {
      return IconButton(
        iconSize: _size,
        icon: Image.asset(
          'assets/icon.png',
          width: _size,
          height: _size,
          color: _color,
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
      );
    } else {
      return Image.asset(
        'assets/icon.png',
        width: _size,
        height: _size,
        color: _color,
      );
    }
  }
}


