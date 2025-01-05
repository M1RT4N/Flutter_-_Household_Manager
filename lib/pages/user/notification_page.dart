import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/widgets/notifications/base_notification.dart';
import 'package:household_manager/widgets/notifications/request_notification.dart';
import 'package:household_manager/widgets/notifications/user_notification.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:rxdart/rxdart.dart';

const _cardBottomPadding = 12.0;
const _cardInnerPadding = 32.0;
const _widthFactor = 0.5;
const _borderRadius = 8.0;
const _boxPadding = 16.0;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final userService = GetIt.instance<UserService>();
  final householdService = GetIt.instance<HouseholdService>();

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Notifications',
      showDrawer: true,
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context) {
    return LoadingStreamBuilder(
      stream: CombineLatestStream.combine2(
        userService.getUserStream,
        householdService.getHouseholdStream,
        (user, household) => [user, household],
      ),
      builder: (context, data) {
        final user = (data as List)[0] as User?;
        final household = (data)[1] as Household?;
        final notifications = user?.notifications ?? [];
        final List<BaseNotification> allNotifications = [
          ...List.generate(
              household?.requested.length ?? 0,
              (index) =>
                  RequestNotification(userId: household?.requested[index])),
          ...notifications.map(
              (notification) => UserNotification(notification: notification)),
        ];

        return ListView.builder(
          padding: EdgeInsets.all(_cardInnerPadding),
          itemCount: allNotifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationCard(context, allNotifications[index]);
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, BaseNotification notification) {
    return Padding(
      padding: EdgeInsets.only(bottom: _cardBottomPadding),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: _widthFactor,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              side: BorderSide(color: Colors.grey[600]!),
            ),
            child: Padding(
              padding: EdgeInsets.all(_boxPadding),
              child: notification.build(context),
            ),
          ),
        ),
      ),
    );
  }
}
