import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:rxdart/rxdart.dart';

const _notificationIconPadding = 10.0;
const _notificationCountBubbleSize = 14.0;
const _notificationCountSize = 10.0;
const _notificationBorderRadius = 6.0;
const _notificationPadding = 12.0;
const _notificationInnerPadding = 2.0;

class NotificationIcon extends StatelessWidget {
  final VoidCallback onPressed;
  final userService = GetIt.instance<UserService>();
  final householdService = GetIt.instance<HouseholdService>();

  NotificationIcon({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return LoadingStreamBuilder(
        stream: CombineLatestStream.combine2(
            userService.getUserStream,
            householdService.getHouseholdStream,
            (user, household) => [user, household]),
        builder: (context, data) {
          final user = (data as List)[0] as User?;
          final household = (data)[1] as Household?;
          final notifications = user?.notifications ?? [];
          final visibleNotifications = notifications
              .where((notification) => !notification.isHidden)
              .toList();
          final notificationCount =
              (household?.requested.length ?? 0) + visibleNotifications.length;

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: _notificationIconPadding),
                child: IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: onPressed,
                ),
              ),
              if (notificationCount > 0)
                _buildNotificationCountBubble(notificationCount),
            ],
          );
        });
  }

  Widget _buildNotificationCountBubble(int notificationCount) {
    return Padding(
      padding: EdgeInsets.only(top: _notificationPadding),
      child: Container(
        padding: EdgeInsets.all(_notificationInnerPadding),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(_notificationBorderRadius),
        ),
        constraints: BoxConstraints(
          minWidth: _notificationCountBubbleSize,
          minHeight: _notificationCountBubbleSize,
        ),
        child: Text(
          notificationCount.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: _notificationCountSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
