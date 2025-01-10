import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_statass PageTemplate extends StatelessWidget {
const _appBarGap = SizedBox(width: 16);
const _appBarNotificationIconPadding = 10.0;
const _appBarNotificationCountBubbleSize = 14.0;
const _appBarNotificationCountSize = 10.0;
const _appBarNotificationBorderRadius = 6.0;
const _appBarNotificationPadding = 12.0;
const _appBarNotificationInnerPadding = 2.0;
const _avatarFontSize = 12.0;
const _avatarRadius = 16.0;
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
          _appBarGap,
          _buildNotificationIcon(),
        ],
        SizedBox(width: _initialsRightPadding),
        UserAvatar(
        _appBarGap,
        IconButton(
          icon: UserAvatar(
            name: appState.user!.name,
            iconRadius: _avatarRadius,
            fontSize: _avatarFontSize,
          ),
          onPressed: () => Modular.to.pushNamed(AppRoute.profile.path),
        ),
        if (showLogout) ...[
          _appBarGap,
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        _appBarGap,
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
