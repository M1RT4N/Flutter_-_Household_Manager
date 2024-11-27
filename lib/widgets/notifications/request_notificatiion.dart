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
              // TODO: implement reject action, so it will delete this notification
              // -> it should be easy because we would not be saving notifications
              // for accepted requests but we would only look for our houshold
              // and add it at top of notifications list...) so we just remove
              // user ID from household requests and add it to household members.
              // Also send to all members (except that new one) notification about it
              // This one can be in style of to do notification or something like that
              // Also send welcom notification to new member
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
              // TODO: for start same as accept but only remove it from requests,
              // but send to all members info about rejection and (this i do not know
              // how  for now but notify also user who requested it)
            }
          },
          icon: Icon(Icons.cancel, color: Colors.red),
        ),
      ],
    );
  }
}
