import 'package:flutter/material.dart';

class PostMedia extends StatelessWidget {
  final String mediaUrl;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const PostMedia({
    super.key,
    required this.mediaUrl,
    this.height = 240,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Image.network(
      mediaUrl,
      height: height,
      fit: BoxFit.fitHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, _, __) {
        return Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        );
      },
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: GestureDetector(
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}