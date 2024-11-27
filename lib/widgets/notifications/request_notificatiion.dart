import 'package:flutter/material.dart';
import 'base_notification.dart';
import 'package:household_manager/utils/utility.dart';

class RequestNotification extends BaseNotification {
  RequestNotification()
      : super(
          icon: Icons.person_add,
          title: '<user> requested joining of household.',
          description:
              'This action will grant access to household data. Once accepted, the member will have full access to shared resources and it will not be possible to remove them without their consent. They will need to leave the household manually if necessary.',
        );

  @override
  Widget buildAction(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            bool? confirmed = await showConfirmationDialog(
              context,
              'Accept Request',
              'Are you sure you want to accept this request?',
            );
            if (confirmed == true) {
              // TODO: implement reject action
            }
          },
          icon: Icon(Icons.check, color: Colors.green),
        ),
        IconButton(
          onPressed: () async {
            bool? confirmed = await showConfirmationDialog(
              context,
              'Reject Request',
              'Are you sure you want to reject this request?',
            );
            if (confirmed == true) {
              // TODO: implement accept action
            }
          },
          icon: Icon(Icons.cancel, color: Colors.red),
        ),
      ],
    );
  }
}
