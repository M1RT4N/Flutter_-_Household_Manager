import 'package:flutter/material.dart';
import 'package:household_manager/pages/auth/login_page.dart';
import 'package:household_manager/pages/household_page.dart';
import 'package:household_manager/services/theme_controller.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/widgets/auth_wrapper.dart';

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
        return MaterialApp(
          title: 'Household Manager',
          theme: snapshot.data,
          home: AuthWrapper(),
          routes: {
            '/login': (context) => LoginPage(),
            '/home': (context) => HomePage(
                profileInfo: IocContainer.getIt<UserService>().userProfile!),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
