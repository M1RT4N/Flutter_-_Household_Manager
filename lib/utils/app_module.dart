import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/pages/home_page.dart';
import 'package:household_manager/pages/household_wizard/choose_household_page.dart';
import 'package:household_manager/pages/household_wizard/create_household_page.dart';
import 'package:household_manager/pages/household_wizard/join_household_page.dart';
import 'package:household_manager/pages/household_wizard/register_page.dart';
import 'package:household_manager/pages/household_wizard/request_household_page.dart';
import 'package:household_manager/pages/login_page.dart';
import 'package:household_manager/utils/guards/auth_guard.dart';
import 'package:household_manager/pages/splash_screen.dart';

class AppModule extends Module {
  @override
  final List<ModularRoute> routes = [
    // Initial route
    ChildRoute(Modular.initialRoute, child: (_, __) => SplashScreen()),

    // Public routes
    ChildRoute('/login', child: (_, __) => LoginPage()),
    ChildRoute('/register', child: (_, __) => RegisterPage()),

    // Protected routes with AuthGuard
    ChildRoute('/home', child: (_, __) => HomePage(), guards: [AuthGuard()]),
    ChildRoute('/choose_household',
        child: (_, __) => ChooseHouseholdPage(), guards: [AuthGuard()]),
    ChildRoute('/household_request',
        child: (_, __) => HouseholdRequestPage(), guards: [AuthGuard()]),
    ChildRoute('/join_household',
        child: (_, __) => JoinHouseholdPage(), guards: [AuthGuard()]),
    ChildRoute('/create_household',
        child: (_, __) => CreateHouseholdPage(), guards: [AuthGuard()]),
  ];
}
