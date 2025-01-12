import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/notification_icon.dart';
import 'package:household_manager/widgets/user_avatar.dart';

const _appBarElevation = 1.0;
const _appBarBorderWidth = 1.0;

abstract class PageTemplate extends StatelessWidget {
  final String title;
  final bool showDrawer;
  final bool showBackArrow;
  final bool showLogout;
  final bool showNotifications;

  const PageTemplate({
    super.key,
    required this.title,
    this.showDrawer = true,
    this.showBackArrow = false,
    this.showLogout = false,
    this.showNotifications = true,
  });

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      elevation: _appBarElevation,
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey,
          width: _appBarBorderWidth,
        ),
      ),
      centerTitle: true,
      leading: showBackArrow
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Modular.to.pop(),
            )
          : null,
      actions: [
        if (showNotifications)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: NotificationIcon(
              onPressed: () =>
                  Modular.to.pushNamed(AppRoute.notifications.path),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: UserAvatar(
            onPressed: () => Modular.to.pushNamed(AppRoute.profile.path),
          ),
        ),
        if (showLogout)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => logout(context),
            ),
          ),
      ],
    );
  }

  void logout(BuildContext context) async {
    final householdService = GetIt.instance<HouseholdService>();
    await Utility.handleActionWithConfirmation(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      action: () async => await householdService.logout() as Future<String?>,
      successMessage: 'Logged out successfully.',
      navigateTo: AppRoute.login.path,
    );
  }
}
