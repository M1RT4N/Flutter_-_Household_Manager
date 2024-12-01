import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/app_drawer.dart';
import 'package:household_manager/widgets/loading_screen.dart';
import 'package:household_manager/widgets/user_avatar.dart';
import 'package:rxdart/rxdart.dart';

const _initialsRightPadding = 16.0;
const _appBarNotificationIconPadding = 10.0;
const _appBarNotificationCountBubbleSize = 14.0;
const _appBarNotificationCountSize = 10.0;
const _appBarNotificationBorderRadius = 6.0;
const _appBarNotificationPadding = 12.0;
const _appBarNotificationInnerPadding = 2.0;

class PageTemplate extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext, AppState) bodyFunction;
  final bool showDrawer;
  final bool showBackArrow;
  final bool showLogout;
  final bool showNotifications;

  const PageTemplate({
    super.key,
    required this.title,
    required this.bodyFunction,
    this.showDrawer = true,
    this.showBackArrow = false,
    this.showLogout = false,
    this.showNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    final appStateStream =
        Rx.combineLatest3<User?, Household?, List<Todo>, AppState>(
      GetIt.instance<UserService>().getUserStream,
      GetIt.instance<HouseholdService>().getHouseholdStream,
      GetIt.instance<TodoService>().getTodoStream,
      (User? user, Household? household, List<Todo> todos) =>
          AppState(user: user, household: household, todos: todos),
    );

    return LoadingStreamBuilder<AppState>(
      stream: appStateStream,
      noDataWidget: LoadingScreen(),
      builder: (_, appState) {
        return Scaffold(
            appBar: _buildAppBar(context, appState),
            drawer: showDrawer
                ? AppDrawer(
                    logoutFunc: _logout,
                  )
                : null,
            body: bodyFunction(context, appState));
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AppState appState) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: showBackArrow
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Modular.to.pop(),
            )
          : null,
      actions: [
        SizedBox(width: _initialsRightPadding),
        if (showNotifications) _buildNotificationIcon(),
        SizedBox(width: _initialsRightPadding),
        UserAvatar(
          name: appState.user?.name,
          onPressed: () => Modular.to.pushNamed(AppRoute.profile.path),
        ),
        if (showLogout) ...[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: _appBarNotificationIconPadding),
          child: IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Modular.to.navigate(AppRoute.notifications.path);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: _appBarNotificationPadding),
          child: Container(
            padding: EdgeInsets.all(_appBarNotificationInnerPadding),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius:
                  BorderRadius.circular(_appBarNotificationBorderRadius),
            ),
            constraints: BoxConstraints(
              minWidth: _appBarNotificationCountBubbleSize,
              minHeight: _appBarNotificationCountBubbleSize,
            ),
            child: Text(
              _getNotificationCount().toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: _appBarNotificationCountSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _logout(BuildContext context) async {
    final householdService = GetIt.instance<HouseholdService>();
    await Utility.handleActionWithConfirmation(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      action: () async => await householdService.logout(),
      successMessage: 'Logged out successfully.',
      navigateTo: AppRoute.login.path,
    );
  }

  int _getNotificationCount() {
    return 5; // TODO: This need to be dynamic, implement after service!!
  }
}
