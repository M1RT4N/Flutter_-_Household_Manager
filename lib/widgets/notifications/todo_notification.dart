import 'package:flutter/material.dart';

import 'base_notification.dart';

class TodoNotification extends BaseNotification {
  TodoNotification({required title, required description})
      : super(title: title, description: description, icon: Icons.assignment);

  @override
  Widget buildAction(BuildContext context) {
    return Container();
    // return IconButton(
    //   onPressed: () async {
    //     bool? confirmed = await showConfirmationDialog(
    //       context,
    //       'Delete Request',
    //       'Are you sure you want to delete this notification?',
    //     );
    //     if (confirmed == true) {
    //       // TODO: Mark notification as deleted, do not delet it for real!
    //       // we will ad in future something to see deleted one
    //     }
    //   },
    //   icon: Icon(Icons.delete, color: Colors.grey),
    // );
  }
}
