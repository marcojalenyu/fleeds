import 'package:flutter/material.dart';

/// A custom card widget with consistent styling.
class CustomCard extends StatelessWidget {

  final Widget child;
  final bool noPadding;

  const CustomCard({
    super.key, 
    required this.child,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      padding: noPadding ? EdgeInsets.zero : const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}


