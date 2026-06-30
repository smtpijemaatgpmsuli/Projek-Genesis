import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appThemeProvider = Provider<ThemeData>((ref) {
  const primaryColor = Color(0xFF1F74D1);
  const secondaryColor = Color(0xFFFFD166);

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
    ),
    fontFamily: 'Inter',
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    useMaterial3: true,
  );
});
