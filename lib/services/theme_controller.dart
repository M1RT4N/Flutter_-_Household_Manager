import 'dart:async';

import 'package:flutter/material.dart';

class ThemeController {
  final StreamController<ThemeData> _themeController =
      StreamController<ThemeData>.broadcast();
  ThemeData _currentTheme = ThemeData.dark();

  Stream<ThemeData> get themeStream => _themeController.stream;
  ThemeData get currentTheme => _currentTheme;

  void toggleTheme(bool isDarkMode) {
    _currentTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    _themeController.add(_currentTheme);
  }

  void dispose() {
    _themeController.close();
  }
}
