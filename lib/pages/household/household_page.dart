import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/household_dto.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/models/household_dto.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/tabs/stat_range.dart';
import 'package:household_manager/utils/tabs/todo_section.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/editable_field.dart';
import 'package:household_manager/widgets/info_bubble.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';
import 'package:household_manager/widgets/todo_tile.dart';
import 'package:rxdart/rxdart.dart';
import 'package:household_manager/widgets/user_avatar.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _elevation = 4.0;
const _borderRadius = 8.0;
const _padding = EdgeInsets.all(16.0);
const _sizedBox = SizedBox(height: 16);
const _buttonsGap = SizedBox(width: 8);
const _buttonWidth = 30.0;
const _cardElevation = 4.0;
const _cardMargin = EdgeInsets.all(20.0);
const innerCardPadding = EdgeInsets.all(16.0);
const _cardBottomPadding = 12.0;
const _maxWidthFactor = 0.5;
const _minWidthFactor = 1.0;
const _mediaControlMinSize = 1000.0;
const _smallUserAvatarRadius = 10.0;
const _smallUserAvatarFontSize = 8.0;

class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate<(Household?, List<Todo>)>(
      title: 'Your Household',
      stream: Rx.combineLatest2(
          GetIt.instance<HouseholdService>().getHouseholdStream,
          GetIt.instance<TodoService>().getTodoStream,
          (household, todos) => (household, todos)),
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
      stream: GetIt.instance<HouseholdService>().getHouseholdStream,
      bodyFunctionPhone: (context, household) =>
          _buildCommonBody(context, household, _buildBodyPhone),
      bodyFunctionWeb: (context, household) =>
          _buildCommonBody(context, household, _buildBodyWeb),
    );
  }

  Widget _buildBodyWeb(BuildContext context, (Household?, List<Todo>) stream) {
    final (household, todos) = stream;
  Widget _buildCommonBody(BuildContext context, Household? household,
      Function(BuildContext, Household, HouseholdDto) bodyFunction) {
    if (household == null) {
      return InfoBubble(labelText: "Household not found.");
    }

    return LoadingFutureBuilder(
      future: GetIt.instance<HouseholdService>().fetchUsers(household),
      builder: (context, householdWithUsers) {
        return SingleChildScrollView(
          padding: _padding,
          child: bodyFunction(context, household, householdWithUsers),
        );
      },
    );
  }

  Widget _buildBodyWeb(BuildContext context, Household household,
      HouseholdDto householdWithUsers) {
    return _buildCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: _buildHouseholdInfoSection(context, household,
                haveAdditionalCard: false),
          ),
          Divider(),
          _sizedBox,
          _buildQRCode(context, household.code, haveAdditionalCard: false),
          _sizedBox,
          _buildMembersSection(context, householdWithUsers.members),
          _sizedBox,
          _buildRequestsSection(context, householdWithUsers.requesters,
              householdWithUsers.household),
          _sizedBox,
          _buildLeaveButton(context),
        ],
      ),
    );
  }
}

Widget _buildBodyPhone(BuildContext context, (Household?, List<Todo>) stream) {
  final (household, todos) = stream;
  if (household == null) {
    return Center(child: Text('No data available.'));
  }

  return LoadingFutureBuilder(
    future: Future.wait([
      GetIt.instance<HouseholdService>().fetchUsers(household),
      GetIt.instance<TodoService>().fetchUsers(
          TodoSection.activeTodo.filter(todos, null, StatRange.AllTime)),
    ]),
    builder: (context, fetched) {
      final household = fetched[0] as HouseholdDto;
      final todos = fetched[1] as List<TodoDto>;

      return SingleChildScrollView(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHouseholdInfoSection(context, household.household),
            _sizedBox,
            _buildMembersSection(context, household.members),
            _sizedBox,
            _buildRequestsSection(context, household.requesters),
            _sizedBox,
            _buildTodosSection(context, todos),
            _sizedBox,
            _buildLeaveButton(context),
          ],
        ),
      );
    },
  );
}

  Widget _buildBodyPhone(BuildContext context, Household household,
      HouseholdDto householdWithUsers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHouseholdInfoSection(context, household),
        _sizedBox,
        _buildQRCode(context, household.code),
        _sizedBox,
        _buildMembersSection(context, householdWithUsers.members),
        _sizedBox,
        _buildRequestsSection(context, householdWithUsers.requesters,
            householdWithUsers.household),
        _sizedBox,
        _buildLeaveButton(context),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: _cardBottomPadding),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: MediaQuery.of(context).size.width > _mediaControlMinSize
              ? _maxWidthFactor
              : _minWidthFactor,
          child: Card(
            elevation: _cardElevation,
            margin: _cardMargin,
            child: Padding(
              padding: innerCardPadding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode(BuildContext context, String code,
      {bool haveAdditionalCard = true}) {
    return cardWrap(
      Column(
        children: [
          if (haveAdditionalCard) _sizedBox,
          Text(
            'Join by QR Code:',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500]),
          ),
          Center(
            child: SizedBox(
              width: 140,
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.grey[500],
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
          _sizedBox,
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Join code: ',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500])),
                Text(code,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                IconButton(
                  onPressed: () => _copyCode(context, code),
                  icon: Icon(Icons.copy),
                ),
              ],
            ),
          ),
          if (haveAdditionalCard) _sizedBox,
        ],
      ),
      haveAdditionalCard,
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
      children: items.isEmpty
          ? [Center(child: Text('No data available'))]
          : items.map(buildItem).toList(),
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

Widget _buildTodosSection(BuildContext context, List<TodoDto> todos) {
  return _buildSection<TodoDto>(
    context: context,
    leadingIcon: const Icon(Icons.list),
    title: 'Active Todos',
    items: todos,
    buildItem: (todo) => TodoTile(
      todo: todo.todo,
      creator: todo.creator,
      assignee: todo.assignee,
      showTickMark: true,
      onClick: () {},
    ),
  );
}
  Widget _buildMembersSection(BuildContext context, List<User> members) {
    return _buildSection<User>(
      context: context,
      leadingIcon: const Icon(Icons.group),
      title: 'Members',
      items: members,
      buildItem: (member) => ListTile(
        title: _buildUserRow(member),
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

  Widget _buildRequestsSection(
      BuildContext context, List<User> requesters, Household household) {
    return _buildSection<User>(
      context: context,
      leadingIcon: const Icon(Icons.mark_as_unread_rounded),
      title: 'Requests',
      items: requesters,
      buildItem: (requester) => ListTile(
        title: _buildUserRow(requester),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingStadiumButton(
              onPressed: () =>
                  _manageRequest(context, requester, true, household.id),
              idleStateWidget: const Icon(Icons.check),
              buttonWidth: _buttonWidth,
            ),
            _buttonsGap,
            LoadingStadiumButton(
              onPressed: () =>
                  _manageRequest(context, requester, false, household.id),
              idleStateWidget: const Icon(Icons.close),
              buttonWidth: _buttonWidth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserAvatar(
          selectedUser: user,
          initialsRadius: _smallUserAvatarRadius,
          initialsFontSize: _smallUserAvatarFontSize,
        ),
        _sizedBox,
        Text(
          ' ${user.name}',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget cardWrap(Widget child, bool haveAdditionalCard) => haveAdditionalCard
      ? Card(
          elevation: _elevation,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius)),
          child: child)
      : child;

  Widget _buildHouseholdInfoSection(BuildContext context, Household household,
      {bool haveAdditionalCard = true}) {
    return cardWrap(
      Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: EditableField(
                labelText: 'Household name: ',
                editableText: household.name,
                onAccept: _renameHousehold,
              ),
            ),
          ],
        ),
      ),
      haveAdditionalCard,
    );
  }

  Future<void> _renameHousehold(BuildContext context, String newName) {
    return Utility.performActionAndShowInfo(
      context: context,
      action: () => GetIt.instance<HouseholdService>().renameHousehold(newName),
      successMessage: 'Household name changed.',
    );
  }

  Future<void> _manageRequest(
      BuildContext context, User requester, bool accept, String householdId) {
    final householdService = GetIt.instance<HouseholdService>();

    return Utility.performActionAndShowInfo(
      context: context,
      action: () async {
        if (accept) {
          return householdService.approveJoinRequest(householdId, requester);
        }
        return householdService.rejectJoinRequest(householdId, requester);
      },
      successMessage: 'Request ${accept ? 'accepted' : 'rejected'}.',
    );
  }

  Future<void> _removeMember(BuildContext context, String member) {
    return Utility.handleActionWithConfirmation(
      context: context,
      title: 'Confirm Kick Member',
      message: 'Are you sure you want to kick selected user?',
      action: () => GetIt.instance<HouseholdService>().removeMember(member),
      errorMessage: 'Failed to kick user from household',
      successMessage: 'Member removed.',
      navigateTo: null,
    );
  }

  Widget _buildLeaveButton(BuildContext context) {
    return Card(
      elevation: _elevation,
      color: Colors.red[900]!.withAlpha(40),
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
}
