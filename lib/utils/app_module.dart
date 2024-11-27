import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/pages/household/home_page.dart';
import 'package:household_manager/pages/household/members_page.dart';
import 'package:household_manager/pages/household/settings.dart';
import 'package:household_manager/pages/household/statistics_page.dart';
import 'package:household_manager/pages/household_wizard/choose_household_page.dart';
import 'package:household_manager/pages/household_wizard/create_household_page.dart';
import 'package:household_manager/pages/household_wizard/join_household_page.dart';
import 'package:household_manager/pages/auth/register_page.dart';
import 'package:household_manager/pages/household_wizard/request_household_page.dart';
import 'package:household_manager/pages/auth/login_page.dart';
import 'package:household_manager/pages/todo/create_todo_page.dart';
import 'package:household_manager/pages/todo/todos_page.dart';
import 'package:household_manager/pages/user/notification_page.dart';
import 'package:household_manager/pages/user/profile_page.dart';
import 'package:household_manager/utils/guards/auth_guard.dart';
import 'package:household_manager/pages/splash_screen.dart';
import 'package:household_manager/utils/utility.dart';

class AppModule extends Module {
  @override
  final List<ModularRoute> routes = [
    // Initial route
    ChildRoute(Modular.initialRoute,
        child: (_, __) => SplashScreen(
              actionCallback: checkAuth,
            )),

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
    ChildRoute('/notifications',
        child: (_, __) => NotificationsPage(), guards: [AuthGuard()]),
    ChildRoute('/profile',
        child: (_, __) => ProfilePage(), guards: [AuthGuard()]),
    ChildRoute('/statistics',
        child: (_, __) => StatisticsPage(), guards: [AuthGuard()]),
    ChildRoute('/members',
        child: (_, __) => MembersPage(), guards: [AuthGuard()]),
    ChildRoute('/create-todo',
        child: (_, __) => CreateTodoPage(), guards: [AuthGuard()]),
    ChildRoute('/todos', child: (_, __) => TodosPage(), guards: [AuthGuard()]),
    ChildRoute('/settings',
        child: (_, __) => SettingsPage(), guards: [AuthGuard()]),
  ];
}
