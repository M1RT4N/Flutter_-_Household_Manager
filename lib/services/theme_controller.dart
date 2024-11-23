import 'dart:async';
import 'package:flutter/material.dart';

class ThemeController {
  final StreamController<ThemeData> _themeContr =
      StreamController<ThemeData>.broadcast();
  ThemeData _currentTheme = ThemeData.dark();

  Stream<ThemeData> get themeStream => _themeContr.stream;
  ThemeData get currentTheme => _currentTheme;

  void toggleTheme(bool isDarkMode) {
    _currentTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    _themeContr.add(_currentTheme);
  }

  void dispose() {
    _themeContr.close();
  }
}
