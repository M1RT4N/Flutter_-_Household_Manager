import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/pages/household_wizard/create_household_page.dart';
import 'package:household_manager/pages/household_wizard/join_household_page.dart';
import 'package:household_manager/pages/household_wizard/request_household_page.dart';
import 'package:household_manager/services/user_service.dart';

const _boxSize = 250.0;
const _mainIconSize = 40.0;
const _mainButtonBorderRadius = 8.0;
const _mainButtonPadding = 16.0;
const _mainButtonFontSize = 16.0;
const _appbarRightPaddingLogout = 24.0;
const _mainButtonGap = 20.0;

class ChooseHouseholdPage extends StatelessWidget {
  const ChooseHouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Choose Household'),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: _appbarRightPaddingLogout),
          child: TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final userService = GetIt.instance<UserService>();
    return FutureBuilder<Map<String, dynamic>>(
      future: userService.fetchUserProfileWithHousehold(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error loading user profile.'));
        }

        ProfileInfo profileInfo = snapshot.data!['profileInfo'];
        Household? household = snapshot.data!['household'];

        if (profileInfo.requestedId != null) {
          return HouseholdRequestPage(hideAppBar: true);
        }

        if (household != null &&
            household.requested
                .contains(FirebaseAuth.instance.currentUser!.uid)) {
          return HouseholdRequestPage(hideAppBar: true);
        }

        return _buildMainContent(context);
      },
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(_mainButtonPadding),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHouseholdButton(
                  context,
                  icon: Icons.home,
                  label: 'Enter Existing Household',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddToHouseholdPage()),
                    );
                  },
                ),
                const SizedBox(width: _mainButtonGap),
                _buildHouseholdButton(
                  context,
                  icon: Icons.add,
                  label: 'Create New Household',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateHouseholdPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseholdButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: _boxSize,
      height: _boxSize,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(_mainButtonPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_mainButtonBorderRadius),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _mainIconSize),
            const SizedBox(height: _appbarRightPaddingLogout / 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: _mainButtonFontSize),
            ),
          ],
        ),
      ),
    );
  }
}
