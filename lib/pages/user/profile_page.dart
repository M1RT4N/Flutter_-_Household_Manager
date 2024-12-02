import 'package:flutter/material.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/page_template.dart';

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Name: ${appState.user!.name}'),
          Text('Username: ${appState.user!.username}'),
          Text('Email: ${appState.user!.email}'),
          Text('Household: ${appState.user!.householdId}'),
        ],
      ),
    );
  }
}
