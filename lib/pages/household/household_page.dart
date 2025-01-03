import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/editable_row.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _middleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
const _elevation = 4.0;
const _borderRadius = 8.0;
const _padding = EdgeInsets.all(16.0);
const _sizedBox = SizedBox(height: 16);

class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Your Household',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    final household = appState.household!;

    return SingleChildScrollView(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHouseholdInfoSection(context, household),
          _sizedBox,
          _buildMembersSection(context, household.members),
          _sizedBox,
          _buildRequestsSection(context, household.requested),
          _sizedBox,
          _buildLeaveButton(context)
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context, List<String> members) {
    return ExpansionTile(
      leading: const Icon(Icons.group),
      title: const Text('Members'),
      children: [
        for (final member in members)
          ListTile(
            title: Text(member),
            trailing: IconButton(
              onPressed: () => _removeMember(context, member),
              icon: Icon(Icons.delete_forever),
            ),
          )
      ],
    );
  }

  Widget _buildRequestsSection(BuildContext context, List<String> requests) {
    return ExpansionTile(
        leading: const Icon(Icons.mark_as_unread_rounded),
        title: const Text('Requests'),
        children: [
          for (final request in requests)
            Row(
              children: [
                Expanded(child: Text(request, overflow: TextOverflow.ellipsis)),
                IconButton(
                  onPressed: () => _manageRequest(context, request, true),
                  icon: Icon(Icons.check),
                ),
                IconButton(
                  onPressed: () => _manageRequest(context, request, false),
                  icon: Icon(Icons.close),
                ),
              ],
            )
        ]);
  }

  Widget _buildHouseholdInfoSection(BuildContext context, Household household) {
    return Card(
      elevation: _elevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius)),
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditableRow(
              leadingText: 'Household name: ',
              editableText: household.name,
              textStyle: _middleTextStyle,
              onAccept: _renameHousehold,
            ),
            _buildInfoTile(
              'Join code: ',
              household.code,
              Icons.copy,
              () => _copyCode(context, household.code),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _renameHousehold(BuildContext context, String newName) async {
    await GetIt.instance<HouseholdService>().renameHousehold(newName);
    if (context.mounted) {
      showTopSnackBar(context, 'Household name changed.', Colors.blue);
    }
  }

  Future<void> _manageRequest(
      BuildContext context, String request, bool accept) async {
    await GetIt.instance<HouseholdService>().manageRequest(request, accept);
    if (context.mounted) {
      showTopSnackBar(
          context, 'Request ${accept ? 'accepted' : 'rejected'}.', Colors.blue);
    }
  }

  Future<void> _removeMember(BuildContext context, String member) async {
    await GetIt.instance<HouseholdService>().removeMember(member);
    if (context.mounted) {
      showTopSnackBar(context, 'Member removed.', Colors.blue);
    }
  }

  Widget _buildInfoTile(String leadingText, String middleText, IconData icon,
      VoidCallback onPress) {
    return Row(
      children: [
        Text(leadingText),
        Text(middleText, style: _middleTextStyle),
        IconButton(
          icon: Icon(icon),
          onPressed: onPress,
        ),
      ],
    );
  }

  Widget _buildLeaveButton(BuildContext context) {
    return Card(
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.exit_to_app,
          color: Colors.red,
        ),
        title: const Text(
          'Leave Household',
          style: TextStyle(color: Colors.red),
        ),
        onTap: () => _leaveHousehold(context),
      ),
    );
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      showTopSnackBar(context, 'Code copied.', Colors.lightBlue);
    }
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
