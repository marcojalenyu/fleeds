import 'package:flutter/material.dart';
import 'package:nota/core/constants/theme.dart';
import 'package:nota/data/services/auth_service.dart';
import 'package:nota/features/auth/presentation/login_screen.dart';
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
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
        '/login': (context) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}