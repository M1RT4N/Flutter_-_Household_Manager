import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/utils/utility.dart';

import 'base_notification.dart';

class RequestNotification extends BaseNotification {
  final User? user;
  final householdService = GetIt.instance<HouseholdService>();

  RequestNotification({required this.user})
      : super(
          icon: Icons.person_add,
          title:
              '${user?.name ?? 'Unknown User'} requested joining of household.',
          description:
              'This action will grant access to household data. Once accepted, the member will have full access to shared resources and it will not be possible to remove them without their consent. They will need to leave the household manually if necessary.',
        );

  Future<void> _handleRequest(BuildContext context, String title,
      String message, Function onConfirm) async {
    bool? confirmed =
        await Utility.showConfirmationDialog(context, title, message);
    if (confirmed == true && user != null) {
      onConfirm();
    }
  }

  @override
  Widget buildAction(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            await _handleRequest(
              context,
              'Accept Request',
              'Are you sure you want to accept this request?',
              () =>
                  householdService.approveJoinRequest(user!.requestedId!, user),
            );
          },
          icon: Icon(Icons.check, color: Colors.green),
        ),
        IconButton(
          onPressed: () async {
            await _handleRequest(
              context,
              'Reject Request',
              'Are you sure you want to reject this request?',
              () =>
                  householdService.rejectJoinRequest(user!.requestedId!, user),
            );
          },
          icon: Icon(Icons.cancel, color: Colors.red),
        ),
      ],
    );
  }
}
