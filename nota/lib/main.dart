import 'package:flutter/material.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/features/auth/presentation/login_screen.dart';
import 'package:nota/features/auth/presentation/signup_screen.dart';
import 'package:nota/features/profile/presentation/profile_screen.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.currentUser != null;

    return MaterialApp(
      title: 'Nota',
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}