import 'package:flutter/material.dart';
import 'package:fleeds/data/services/auth_service.dart';

/// Widget that ensures user is authenticated before showing child widget
class AuthWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    AuthService.requireAuth(context);
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return widget.child;
  }
}