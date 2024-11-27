import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/services/theme_controller.dart';
import 'package:household_manager/utils/ioc_container.dart';

class HouseholdManagerApp extends StatelessWidget {
  HouseholdManagerApp({super.key});

  final ThemeController _themeController =
      IocContainer.getIt<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeData>(
      stream: _themeController.themeStream,
      initialData: _themeController.currentTheme,
      builder: (context, snapshot) {
        return MaterialApp.router(
          title: 'Household Manager',
          theme: snapshot.data,
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
