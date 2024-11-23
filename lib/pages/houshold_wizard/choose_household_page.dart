import 'package:flutter/material.dart';
import 'package:household_manager/pages/houshold_wizard/create_household_page.dart';
import 'package:household_manager/pages/houshold_wizard/join_household_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                Future.microtask(() {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
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
                  onPressed: () => Future.microtask(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddToHouseholdPage()));
                  }),
                ),
                const SizedBox(width: _mainButtonGap),
                _buildHouseholdButton(
                  context,
                  icon: Icons.add,
                  label: 'Create New Household',
                  onPressed: () => Future.microtask(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CreateHouseholdPage()));
                  }),
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
