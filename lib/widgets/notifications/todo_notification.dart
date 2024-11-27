import 'package:flutter/material.dart';
import 'base_notification.dart';
import 'package:household_manager/utils/utility.dart';

class TodoNotification extends BaseNotification {
  TodoNotification({required title, required description})
      : super(title: title, description: description, icon: Icons.assignment);

  @override
  Widget buildAction(BuildContext context) {
    return IconButton(
      onPressed: () async {
        bool? confirmed = await showConfirmationDialog(
          context,
          'Delete Request',
          'Are you sure you want to delete this notification?',
        );
        if (confirmed == true) {
          // TODO: Implement delete action
        }
      },
      icon: Icon(Icons.delete, color: Colors.grey),
    );
  }
}
