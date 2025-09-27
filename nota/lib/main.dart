import 'package:flutter/material.dart';
import 'package:nota/core/constants/theme.dart';
import 'package:nota/features/login/presentation/login_screen.dart';
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
    return MaterialApp(
      title: 'Nota',
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}