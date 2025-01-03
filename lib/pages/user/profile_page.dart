import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/editable_field.dart';
import 'package:household_manager/widgets/info_field.dart';
import 'package:household_manager/widgets/user_avatar.dart';

const _padding = EdgeInsets.all(16.0);
const _avatarSectionGap = SizedBox(height: 20);
const _borderRadius = 12.0;
const _elevation = 4.0;
const _avatarRadius = 50.0;
const _avatarFontSize = 32.0;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Your Profile',
      bodyFunction: _buildBody,
      showDrawer: false,
      showBackArrow: true,
      showNotifications: false,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    final user = appState.user!;
    return Center(
      child: Padding(
        padding: _padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(
              name: user.name,
              iconRadius: _avatarRadius,
              fontSize: _avatarFontSize,
            ),
            _avatarSectionGap,
            _buildInfoCard(user),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(User user) {
    return Card(
      elevation: _elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditableField(
              labelText: 'Name',
              editableText: user.name,
              onAccept: _changeName,
            ),
            EditableField(
              labelText: 'Username',
              editableText: user.username,
              onAccept: _changeUsername,
            ),
            EditableField(
              labelText: 'Email',
              editableText: user.email,
              onAccept: _changeEmail,
            ),
            InfoField(
              labelText: 'Household',
              mainText: user.householdId ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeName(BuildContext context, String newName) async {
    Utility.performActionAndShowInfo(
      context,
      () => GetIt.instance<UserService>().changeName(newName),
      'Name changed.',
    );
  }

  Future<void> _changeUsername(BuildContext context, String newUsername) async {
    Utility.performActionAndShowInfo(
      context,
      () => GetIt.instance<UserService>().changeUsername(newUsername),
      'Username changed.',
    );
  }

  Future<void> _changeEmail(BuildContext context, String newEmail) async {
    Utility.performActionAndShowInfo(
      context,
      () => GetIt.instance<UserService>().changeEmail(newEmail),
      'Email changed.',
    );
  }
}
