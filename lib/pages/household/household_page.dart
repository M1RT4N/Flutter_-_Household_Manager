import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/snack_bar.dart';

class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Household',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context) {
    return LoadingStreamBuilder(
      stream: GetIt.instance<HouseholdService>().getHouseholdStream,
      builder: (context, household_) {
        var household = household_! as Household;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${household.name}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Code: ${household.code}'),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: household.code),
                      );
                      if (context.mounted) {
                        showTopSnackBar(
                            context, 'Code copied.', Colors.lightBlue);
                      }
                    },
                  ),
                ],
              ),
              Text('Members: ${household.members.toString()}'),
              Text('Requests: ${household.requested.toString()}'),
              ListTile(
                leading: Icon(Icons.login_outlined),
                title: Text('Leave Household'),
                onTap: () => _leaveHousehold(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _leaveHousehold(BuildContext context) async {
    final userService = GetIt.instance<UserService>();
    final householdService = GetIt.instance<HouseholdService>();
    await Utility.handleActionWithConfirmation(
      context: context,
      title: 'Confirm Leave Household',
      message: 'Are you sure you want to leave the household?',
      action: () async {
        if (userService.getUser?.householdId != null) {
          final errorMessage = await householdService.tryLeaveHousehold();
          if (errorMessage != null) {
            throw Exception(errorMessage);
          }
        }
      },
      successMessage: 'Household left.',
      errorMessage: 'Failed to leave household',
      navigateTo: AppRoute.chooseHousehold.route,
    );
  }
}
