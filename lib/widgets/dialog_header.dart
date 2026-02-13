import 'package:flutter/material.dart';

/// A reusable header widget for dialogs, featuring a title, an optional close button, and an optional action button.
class DialogHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const DialogHeader({
    super.key,
    required this.title,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (onActionPressed != null && actionText != null)
            ElevatedButton(
              onPressed: onActionPressed,
              child: Text(actionText!),
            ),
        ],
      ),
    );
  }
}