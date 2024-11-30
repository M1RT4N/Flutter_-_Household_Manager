import 'package:flutter/material.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/test_page_template.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TestPageTemplate(
      title: 'ProfilePage',
      bodyFunction: _buildBody,
      showDrawer: false,
      showBackArrow: true,
      showNotifications: false,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    return Center(
      child: Text('ProfilePage'),
    );
  }
}
