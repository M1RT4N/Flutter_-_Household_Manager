import 'package:flutter/material.dart';
import 'package:household_manager/common/page_template.dart';
import 'package:household_manager/widgets/notifications/base_notification.dart';
import 'package:household_manager/widgets/notifications/request_notificatiion.dart';
import 'package:household_manager/widgets/notifications/todo_notification.dart';

const _cardBottomPadding = 12.0;
const _cardInnerPadding = 32.0;
const _widthFactor = 0.5;
const _borderRadius = 8.0;
const _boxPadding = 16.0;

class NotificationsPage extends StatelessWidget {
  final List<BaseNotification> notifications = [
    RequestNotification(),
    RequestNotification(),
    TodoNotification(
        title: 'New TODO assigned',
        description: 'Someone assigned TODO to you and you need to do it.'),
    RequestNotification(), // TODO: implement if serivce is ready, pass user
  ];

  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Notifications',
      child: ListView(
        padding: EdgeInsets.all(_cardInnerPadding),
        children: notifications
            .map(
                (notification) => _buildNotificationCard(context, notification))
            .toList(),
      ),
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
