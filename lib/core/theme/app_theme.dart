import 'package:flutter/material.dart';

class AppTheme {
  static final light = _theme(Brightness.light, const Color(0xFF6750A4));
  static final dark = _theme(Brightness.dark, const Color(0xFFD0BCFF));
  static ThemeData _theme(Brightness brightness, Color seed) => ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}
