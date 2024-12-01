import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';

class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Household',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Name: ${appState.household!.name}'),
          Text('Code: ${appState.household!.code}'),
          Text('Members: ${appState.household!.members.toString()}'),
          Text('Requests: ${appState.household!.requested.toString()}'),
          ListTile(
            leading: Icon(Icons.login_outlined),
            title: Text('Leave Household'),
            onTap: () => _leaveHousehold(context),
          ),
        ],
      ),
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
