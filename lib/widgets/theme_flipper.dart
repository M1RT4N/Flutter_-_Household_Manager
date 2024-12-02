import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/theme_controller.dart';

class ThemeFlipper extends StatelessWidget {
  const ThemeFlipper({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = GetIt.instance<ThemeController>();

    return StreamBuilder<ThemeData>(
      stream: themeController.themeStream,
      initialData: themeController.currentTheme,
      builder: (context, snapshot) {
        bool isDarkMode = snapshot.data?.brightness == Brightness.dark;

        return IconButton(
          icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: () {
            themeController.toggleTheme(!isDarkMode);
          },
        );
      },
    );
  }
}
