import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:fleeds/core/constants/theme.dart';
import 'package:fleeds/data/services/auth_service.dart';
import 'package:fleeds/features/login/presentation/login_screen.dart';
import 'package:fleeds/features/post/presentation/post_screen.dart';
import 'package:fleeds/features/profile/presentation/profile_screen.dart';
import 'package:fleeds/firebase_options.dart';
import 'features/home/presentation/home_screen.dart';

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
      routes: {
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          final keywords = settings.arguments as List<String>?;
          return MaterialPageRoute(
            builder: (context) => HomeScreen(keywords: keywords),
            settings: settings,
          );
        }
        if (settings.name != null && settings.name!.startsWith('/profile/')) {
          final userId = settings.name!.substring('/profile/'.length);
          return MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userId),
            settings: settings,
          );
        }
        if (settings.name != null && settings.name!.startsWith('/post/')) {
          final postId = settings.name!.substring('/post/'.length);
          final args = settings.arguments as Map<String, dynamic>?;

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
        return null;
      },
    );
  }
}

