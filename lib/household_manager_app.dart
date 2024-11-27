import 'package:flutter/material.dart';
import 'package:household_manager/pages/home_page.dart';
import 'package:household_manager/pages/login_page.dart';
import 'package:household_manager/services/theme_controller.dart';
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
          initialRoute: if userController'/login',
          routes: {
            '/login': (_) => LoginPage(),
            // '/register': (_) => RegisterPage(),
            // '/choose_household': (_) => ChooseHouseholdPage(),
            '/home': (_) => HomePage(),
            // '/household_request': (_) => HouseholdRequestPage(),
            // '/join_household': (_) => JoinHouseholdPage(),
            // '/create_household': (_) => CreateHouseholdPage(),
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
