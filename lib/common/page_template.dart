import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/app_drawer.dart';

const _initialsSize = 12.0;
const _initialsRadius = 16.0;
const _initialsRightPadding = 16.0;

class PageTemplate extends StatelessWidget {
  final String title;
  final Widget child;

  PageTemplate({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  final userService = GetIt.instance<UserService>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!userService.isLoggedIn) {
        return; // Not logged in
      }
      await userService.fetchUserProfile();
      if (userService.householdId == null && context.mounted) {
        Modular.to.navigate('/choose_household');
      }
    });

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // _buildBreadcrumb(),
          Expanded(child: child),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        _buildUserAvatar(context),
        SizedBox(width: _initialsRightPadding),
      ],
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    String initials = _getUserInitials();

    return IconButton(
      icon: CircleAvatar(
        radius: _initialsRadius,
        backgroundColor: Colors.blue,
        child: Text(
          initials,
          style: TextStyle(color: Colors.white, fontSize: _initialsSize),
        ),
      ),
      onPressed: () {
        Modular.to.navigate('/profile');
      },
    );
  }

  String _getUserInitials() {
    final userProfile = userService.userProfile;
    if (userProfile != null && userProfile.name.isNotEmpty) {
      return userProfile.name.trim().split(' ').map((e) => e[0]).take(2).join();
    }
    return '';
  }
}
