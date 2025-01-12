import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/pages/auth/login_page.dart';
import 'package:household_manager/pages/auth/register_page.dart';
import 'package:household_manager/pages/household/home_page.dart';
import 'package:household_manager/pages/household/household_page.dart';
import 'package:household_manager/pages/household/statistics_page.dart';
import 'package:household_manager/pages/household_wizard/choose_household_page.dart';
import 'package:household_manager/pages/household_wizard/create_household_page.dart';
import 'package:household_manager/pages/household_wizard/join_household_page.dart';
import 'package:household_manager/pages/household_wizard/request_household_page.dart';
import 'package:household_manager/pages/splash_screen.dart';
import 'package:household_manager/pages/todo/edit_todo_page.dart';
import 'package:household_manager/pages/todo/my_todos_page.dart';
import 'package:household_manager/pages/user/notification_page.dart';
import 'package:household_manager/pages/user/profile_page.dart';
import 'package:household_manager/utils/guards/household_guard.dart';
import 'package:household_manager/utils/guards/user_guard.dart';
import 'package:household_manager/utils/routing/guard_level.dart';

// HOW to work with routing: Add new enum element to AppRoutes, add to it its path
// page instance, and if it requires authentication. That's it... everything will be
// handled automatically and you can (and must) use AppRoutes.<path_name> in routing.
enum AppRoute {
  initialRoute('/', SplashScreen(), guardLevel: GuardLevel.none),
  register('/register', RegisterPage(), guardLevel: GuardLevel.none),
  login('/login', LoginPage(), guardLevel: GuardLevel.none),
  home('/home', HomePage(), guardLevel: GuardLevel.householdFetched),
  chooseHousehold('/choose_household', ChooseHouseholdPage(),
      guardLevel: GuardLevel.pendingRequest),
  householdRequest('/household_request', HouseholdRequestPage(),
      guardLevel: GuardLevel.userFetched),
  joinHousehold('/join_household', JoinHouseholdPage(),
      guardLevel: GuardLevel.userFetched),
  createHousehold('/create_household', CreateHouseholdPage(),
      guardLevel: GuardLevel.userFetched),
  notifications('/notifications', NotificationsPage(),
      guardLevel: GuardLevel.householdFetched),
  profile('/profile', ProfilePage(), guardLevel: GuardLevel.userFetched),
  statistics('/statistics', StatisticsPage(),
      guardLevel: GuardLevel.householdFetched),
  household('/household', HouseholdPage(),
      guardLevel: GuardLevel.householdFetched),
  editTodo('/edit_todo', EditTodoPage(),
      guardLevel: GuardLevel.householdFetched),
  myTodos('/todos', MyTodosPage(), guardLevel: GuardLevel.householdFetched);

  final String path;
  final Widget pageType;
  final GuardLevel guardLevel;

  const AppRoute(this.path, this.pageType,
      {this.guardLevel = GuardLevel.householdFetched});

  List<RouteGuard> get guards {
    switch (guardLevel) {
      case GuardLevel.userFetched:
        return [UserGuard()];
      case GuardLevel.householdFetched:
        return [UserGuard(), HouseholdGuard()];
      case GuardLevel.pendingRequest:
        // TODO: Reintroduce RequestGuard, but! watch for behaviour
        //       when user is rejected!
        return [UserGuard()];
      default:
        return [];
    }
  }

  String get route => path;
}
