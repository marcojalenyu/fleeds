import 'package:fleeds/authentication/auth_wrapper.dart';
import 'package:fleeds/features/screens/error/presentation/error_screen.dart';
import 'package:fleeds/features/screens/home/presentation/home_screen.dart';
import 'package:fleeds/features/screens/login/presentation/login_screen.dart';
import 'package:fleeds/features/screens/notifications/presentation/notifications_screen.dart';
import 'package:fleeds/features/screens/post/presentation/post_screen.dart';
import 'package:fleeds/features/screens/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';

/// Centralized router for the Fleeds app, 
/// defining all routes and their corresponding screens.
/// Note: Not wrapped by AuthWrapper = accessible without authentication
class AppRouter {

  static const String home = '/';
  static const String login = '/login';
  static const String notifications = '/notifications';

  /// Static routes without dynamic parameters
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => LoginScreen(),
    notifications: (context) => AuthWrapper(child: NotificationsScreen()),
  };

  /// Handle dynamic routes with parameters (posts, other profiles, etc.)
  /// This is used in the onGenerateRoute callback of MaterialApp
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    
    /// Home route with optional keywords argument (for search results) 
    if (settings.name == home) {
      final keywords = settings.arguments as List<String>?;
      return MaterialPageRoute(
        builder: (context) => HomeScreen(keywords: keywords),
        settings: settings,
      );
    }

    /// Dynamic profile route (e.g. /profile/12345)
    if (settings.name != null && settings.name!.startsWith('/profile')) {
      /// Extract userId from the route (if present) and pass it to ProfileScreen
      final userId = settings.name!.startsWith('/profile/') 
        ? _extractPathParameter(settings.name!, '/profile/') 
        : '';
      /// If no userId in path, show current user's profile (handled by ProfileScreen)
      if (userId.isEmpty) {
        return MaterialPageRoute(
          builder: (context) => AuthWrapper(child: ProfileScreen()),
          settings: settings,
        );
      } else {
        return MaterialPageRoute(
          builder: (context) => ProfileScreen(userId: userId),
          settings: settings,
        );
      }
    }

    /// Dynamic post route (e.g. /post/67890)
    if (settings.name != null && settings.name!.startsWith('/post/')) {
      final postId = _extractPathParameter(settings.name!, '/post/');
      final args = settings.arguments as Map<String, dynamic>?;
      /// If post and user data are provided in arguments, 
      /// pass them to the PostScreen for faster loading
      /// Otherwise, just pass the postId and let PostScreen fetch the data
      if (args != null && args['post'] != null && args['user'] != null) {
        return MaterialPageRoute(
          builder: (context) => PostScreen(
            postId: postId,
            post: args['post'],
            user: args['user'],
          ),
          settings: settings,
        );
      } else {
        return MaterialPageRoute(
          builder: (context) => PostScreen(postId: postId),
          settings: settings,
        );
      }
    }

    /// If no match, show an error screen for unknown route
    return MaterialPageRoute(
      builder: (context) => ErrorScreen(message: "Unknown route: ${settings.name}"),
      settings: settings,
    );
  }

  /// Fallback for completely unknown routes (not caught by onGenerateRoute)
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => ErrorScreen(message: "Unknown route: ${settings.name}"),
      settings: settings,
    );
  }

  static String _extractPathParameter(String route, String prefix) {
    return route.substring(prefix.length);
  }
}