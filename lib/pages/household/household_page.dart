import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/editable_field.dart';
import 'package:household_manager/widgets/info_field.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _elevation = 4.0;
const _borderRadius = 8.0;
const _padding = EdgeInsets.all(16.0);
const _sizedBox = SizedBox(height: 16);
const _buttonsGap = SizedBox(width: 8);
const _buttonWidth = 30.0;

class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate<Household?>(
      title: 'Your Household',
      stream: GetIt.instance<HouseholdService>().getHouseholdStream,
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
    );
  }

  Widget _buildBodyWeb(BuildContext context, Household? household) {
    if (household == null) {
      return Center(child: Text('No data available.'));
    }

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
                onPressed: () => _copyCode(context, household.code),
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
  }
}

Widget _buildBodyPhone(BuildContext context, Household? household) {
  if (household == null) {
    return Center(child: Text('No data available.'));
  }

  return LoadingFutureBuilder(
    future: GetIt.instance<HouseholdService>().fetchAdditionalData(household),
    builder: (context, result) {
      return SingleChildScrollView(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHouseholdInfoSection(context, household),
            _sizedBox,
            _buildMembersSection(context, result.members),
            _sizedBox,
            _buildRequestsSection(context, result.requesters),
            _sizedBox,
            _buildLeaveButton(context),
          ],
        ),
      );
    },
  );
}

Widget _buildSection<T>({
  required BuildContext context,
  required Icon leadingIcon,
  required String title,
  required List<T> items,
  required Widget Function(T item) buildItem,
}) {
  return ExpansionTile(
    leading: leadingIcon,
    title: Text(title),
    children: items.map(buildItem).toList(),
  );
}

Widget _buildMembersSection(BuildContext context, List<User> members) {
  return _buildSection<User>(
    context: context,
    leadingIcon: const Icon(Icons.group),
    title: 'Members',
    items: members,
    buildItem: (member) => ListTile(
      title: Text(member.name),
      trailing: GetIt.instance<UserService>().getUser!.id != member.id
          ? LoadingStadiumButton(
              onPressed: () => _removeMember(context, member.id),
              idleStateWidget: const Icon(Icons.delete_forever),
              buttonWidth: _buttonWidth,
            )
          : const Text('You  '),
    ),
  );
}

Widget _buildRequestsSection(BuildContext context, List<User> requesters) {
  return _buildSection<User>(
    context: context,
    leadingIcon: const Icon(Icons.mark_as_unread_rounded),
    title: 'Requests',
    items: requesters,
    buildItem: (requester) => ListTile(
      title: Text(requester.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingStadiumButton(
            onPressed: () => _manageRequest(context, requester.id, true),
            idleStateWidget: const Icon(Icons.check),
            buttonWidth: _buttonWidth,
          ),
          _buttonsGap,
          LoadingStadiumButton(
            onPressed: () => _manageRequest(context, requester.id, false),
            idleStateWidget: const Icon(Icons.close),
            buttonWidth: _buttonWidth,
          ),
        ],
      ),
    ),
  );
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
          EditableField(
            labelText: 'Household name: ',
            editableText: household.name,
            onAccept: _renameHousehold,
          ),
          InfoField(
            labelText: 'Join code',
            mainText: household.code,
            trailingWidget: IconButton(
              onPressed: () => _copyCode(context, household.code),
              icon: Icon(Icons.copy),
            ),
          )
        ],
      ),
    ),
  );
}

Future<void> _renameHousehold(BuildContext context, String newName) {
  return Utility.performActionAndShowInfo(
    context: context,
    action: () => GetIt.instance<HouseholdService>().renameHousehold(newName),
    successMessage: 'Household name changed.',
  );
}

Future<void> _manageRequest(BuildContext context, String request, bool accept) {
  return Utility.performActionAndShowInfo(
    context: context,
    action: () =>
        GetIt.instance<HouseholdService>().manageRequest(request, accept),
    successMessage: 'Request ${accept ? 'accepted' : 'rejected'}.',
  );
}

Future<void> _removeMember(BuildContext context, String member) {
  return Utility.performActionAndShowInfo(
    context: context,
    action: () => GetIt.instance<HouseholdService>().removeMember(member),
    successMessage: 'Member removed.',
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
      return null;
    },
    successMessage: 'Household left.',
    errorMessage: 'Failed to leave household',
    navigateTo: AppRoute.chooseHousehold.route,
  );
}
