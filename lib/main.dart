import 'package:fleeds/authentication/auth_wrapper.dart';
import 'package:fleeds/features/screens/notifications/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:fleeds/core/constants/theme.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/screens/login/presentation/login_screen.dart';
import 'package:fleeds/features/screens/post/presentation/post_screen.dart';
import 'package:fleeds/features/screens/profile/presentation/profile_screen.dart';
import 'package:fleeds/firebase_options.dart';
import 'features/screens/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await AuthService.initializeCurrentUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleeds',
      theme: AppTheme.theme,
      initialRoute: '/',
      home: AuthWrapper(child: HomeScreen()),
      routes: {
        '/login': (context) => LoginScreen(),
        '/profile': (context) => AuthWrapper(child: ProfileScreen()),
        '/notifications': (context) => AuthWrapper(child: NotificationsScreen()),
      },
      onGenerateRoute: (settings) {
        /// Handle the home screen route with optional keywords argument
        if (settings.name == '/') {
          final keywords = settings.arguments as List<String>?;
          return MaterialPageRoute(
            builder: (context) => AuthWrapper(child: HomeScreen(keywords: keywords)),
            settings: settings,
          );
        }
        /// Handle dynamic routes for profile and post screens
        if (settings.name != null && settings.name!.startsWith('/profile/')) {
          final userId = settings.name!.substring('/profile/'.length);
          return MaterialPageRoute(
            builder: (context) => AuthWrapper(child: ProfileScreen(userId: userId)),
            settings: settings,
          );
        }
        if (settings.name != null && settings.name!.startsWith('/post/')) {
          final postId = settings.name!.substring('/post/'.length);
          final args = settings.arguments as Map<String, dynamic>?;

          if (args != null && args['post'] != null && args['user'] != null) {
            return MaterialPageRoute(
              builder: (context) => AuthWrapper(
                child: PostScreen(
                  postId: postId,
                  post: args['post'],
                  user: args['user'],
                ),
              ),
              settings: settings,
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => AuthWrapper(child: PostScreen(postId: postId)),
              settings: settings,
            );
          }
        }
        return null;
      },
    );
  }
}


