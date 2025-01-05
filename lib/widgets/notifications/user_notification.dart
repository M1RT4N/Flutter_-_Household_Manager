import 'package:flutter/material.dart';
import 'package:household_manager/models/user.dart' as models;
import 'package:household_manager/utils/utility.dart';

import 'base_notification.dart';

class UserNotification extends BaseNotification {
  final models.Notification notification;

  UserNotification({required this.notification})
      : super(
            title: notification.title,
            description: notification.description,
            icon: Icons.assignment);

  @override
  Widget buildAction(BuildContext context) {
    return IconButton(
      onPressed: () async {
        bool? confirmed = await Utility.showConfirmationDialog(
          context,
          'Delete Request',
          'Are you sure you want to delete this notification?',
        );
        if (confirmed == true) {
          // TODO: Mark notification as deleted, do not delet it for real!
          // we will ad in future something to see deleted one
        }
      },
      icon: Icon(Icons.delete, color: Colors.grey),
    );
  }
}
