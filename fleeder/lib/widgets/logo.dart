import 'package:flutter/material.dart';

class ClickableLogo extends Logo {
  const ClickableLogo({
    super.key, 
    super.size, 
    super.color,
  }) : super(isButton: true);
}

class Logo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isButton;

  const Logo(
    {
      super.key, 
      this.size = 64.0, 
      this.color,
      this.isButton = false
    }
  );

  @override
  Widget build(BuildContext context) {
    if (isButton) {
      return IconButton(
        iconSize: size, // Ensure IconButton uses your size
        icon: Image.asset(
          'assets/icon.png',
          width: size,
          height: size,
          color: color,
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
      );
    } else {
      return Image.asset(
        'assets/icon.png',
        width: size,
        height: size,
        color: color,
      );
    }
  }
}
