import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/app_drawer.dart';
import 'package:household_manager/widgets/notification_icon.dart';
import 'package:household_manager/widgets/user_avatar.dart';

const _initialsRightPadding = 16.0;

class PageTemplate extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext) bodyFunction;
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
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: showDrawer ? AppDrawer(logoutFunc: _logout) : null,
      body: bodyFunction(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
        if (showNotifications) ...[
          SizedBox(width: _initialsRightPadding),
          NotificationIcon(
              onPressed: () =>
                  Modular.to.pushNamed(AppRoute.notifications.path)),
        ],
        SizedBox(width: _initialsRightPadding),
        UserAvatar(
          onPressed: () => Modular.to.pushNamed(AppRoute.profile.path),
        ),
        if (showLogout) ...[
          SizedBox(width: _initialsRightPadding),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        SizedBox(width: _initialsRightPadding),
      ],
    );
  }

  void _logout(BuildContext context) async {
    final userService = GetIt.instance<UserService>();
    await Utility.handleActionWithConfirmation(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      action: () async => await userService.logout(),
      successMessage: 'Logged out successfully.',
      navigateTo: AppRoute.login.path,
    );
  }
}
