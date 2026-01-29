import 'package:flutter/material.dart';
import 'package:nota/core/constants/constants.dart';

class AppTheme {

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          surfaceTintColor: primaryColor,
          foregroundColor: primaryColor,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 1,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: Colors.blueAccent,
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(
          surfaceTintColor: Colors.white,
          color: Colors.black87,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      );
}