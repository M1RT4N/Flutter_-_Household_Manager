import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/utils/guards/auth_guard.dart';
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
import 'package:household_manager/pages/splash_screen.dart';
import 'package:household_manager/utils/utility.dart';

// HOW to work with routing: Add new enum element to AppRoutes, add to it its path
// page instance, and if it requires authentication. Thats it... everything will be
// handled automaticaly and you can (and must) use AppRoutes.<path_name> in routing.
enum AppRoute {
  initialRoute(
      '/',
      SplashScreen(
        actionCallback: checkAuth,
      )),
  login('/login', LoginPage()),
  register('/register', RegisterPage()),
  home('/home', HomePage(), requiresAuth: true),
  chooseHousehold('/choose_household', ChooseHouseholdPage(),
      requiresAuth: true),
  householdRequest('/household_request', HouseholdRequestPage(),
      requiresAuth: true),
  joinHousehold('/join_household', JoinHouseholdPage(), requiresAuth: true),
  createHousehold('/create_household', CreateHouseholdPage(),
      requiresAuth: true),
  notifications('/notifications', NotificationsPage(), requiresAuth: true),
  profile('/profile', ProfilePage(), requiresAuth: true),
  statistics('/statistics', StatisticsPage(), requiresAuth: true),
  members('/members', MembersPage(), requiresAuth: true),
  createTodo('/create-todo', CreateTodoPage(), requiresAuth: true),
  todos('/todos', TodosPage(), requiresAuth: true),
  settings('/settings', SettingsPage(), requiresAuth: true);

  final String path;
  final Widget pageType;
  final bool requiresAuth;
  const AppRoute(this.path, this.pageType, {this.requiresAuth = false});

  List<RouteGuard> get guards => requiresAuth ? [AuthGuard()] : [];

  String get route => path;
}
