import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _mainBoxPadding = 24.0;
const _pendingSize = 100.0;
const _pendingIconSize = 80.0;
const _pendingGapSize = 20.0;
const _cancelButtonWidth = 200.0;
const _cancelButtonHeight = 50.0;
const _cancelButtonFontSize = 16.0;
const _textFontSize = 18.0;
const _warningBoxPadding = 16.0;
const _warningBoxRadius = 8.0;

class HouseholdRequestPage extends StatelessWidget {
  final bool hideAppBar;

  const HouseholdRequestPage({super.key, this.hideAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hideAppBar ? null : _buildAppBar(context),
      body: Center(
        child: _buildPendingContent(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Household Request Status'),
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: _mainBoxPadding),
          child: TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () => logout(context, GetIt.instance<UserService>()),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _pendingSize,
          height: _pendingSize,
          child: RotationTransition(
            turns: AlwaysStoppedAnimation(0.5),
            child: Icon(
              Icons.sync,
              size: _pendingIconSize,
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(height: _pendingGapSize),
        _buildWarningBox(),
        SizedBox(height: _pendingGapSize),
        _buildCancelButton(context),
      ],
    );
  }

  Card _buildWarningBox() {
    return Card(
      color: Colors.yellow[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_warningBoxRadius),
        side: BorderSide(color: Colors.yellow),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_warningBoxPadding),
        child: Text(
          'Please wait while we await confirmation from your household members.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _textFontSize, color: Colors.black87),
        ),
      ),
    );
  }

  SizedBox _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: _cancelButtonWidth,
      height: _cancelButtonHeight,
      child: ElevatedButton(
        onPressed: () => _cancelRequest(context),
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: Text(
          'Cancel Request',
          style: TextStyle(fontSize: _cancelButtonFontSize),
        ),
      ),
    );
  }

  void _cancelRequest(BuildContext context) async {
    final userService = GetIt.instance<UserService>();
    final householdService = GetIt.instance<HouseholdService>();
    String? householdId = userService.userProfile?.requestedId;
    if (householdId != null) {
      try {
        await householdService.cancelHouseholdRequestByCode(householdId);
        await userService
            .updateUserProfile({'requestedId': FieldValue.delete()});
        userService.setUserProfile({
          ...userService.userProfile!.toMap(),
          'requestedId': null,
        }, userService.userProfile!.id);

        if (context.mounted) {
          showTopSnackBar(
              context, 'Request cancelled successfully.', Colors.green);
          Modular.to.navigate(AppRoute.chooseHousehold.path);
        }
      } catch (e) {
        if (context.mounted) {
          showTopSnackBar(context, 'Failed to cancel request: $e', Colors.red);
        }
      }
    }
  }
}
