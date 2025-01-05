import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/user.dart' as models;
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';

import 'base_notification.dart';

class UserNotification extends BaseNotification {
  final models.Notification notification;

  final _userService = GetIt.instance<UserService>();

  UserNotification({required this.notification})
      : super(
          title: notification.title,
          description: notification.description,
          icon: notification.type.getIcon(),
        );

  @override
  Widget buildAction(BuildContext context) {
    if (notification.isHidden) {
      return SizedBox.shrink();
    }
    return IconButton(
      onPressed: () async {
        bool? confirmed = await Utility.showConfirmationDialog(
          context,
          'Delete Request',
          'Are you sure you want to delete this notification?',
        );
        if (confirmed == true) {
          await _userService.hideNotification(notification.id);
        }
      },
      icon: Icon(Icons.delete, color: Colors.grey),
    );
  }
}
