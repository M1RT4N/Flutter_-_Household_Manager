import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/user_service.dart';

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

  Widget _buildBody(BuildContext context) {
    return LoadingStreamBuilder(
      stream: GetIt.instance<UserService>().getUserStream,
      builder: (context, user_) {
        final user = user_! as User;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Name: ${user.name}'),
              Text('Username: ${user.username}'),
              Text('Email: ${user.email}'),
              Text('Household: ${user.householdId}'),
            ],
          ),
        );
      },
    );
  }
}
