import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/drawer_item.dart';
import 'package:household_manager/widgets/theme_flipper.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final userService = GetIt.instance<UserService>();

  AppDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Text('Household Manager'),
          ),
          Expanded(
            child: ListView(children: [
              DrawerItem(
                title: 'Household',
                icon: Icons.house,
                isSelected: currentRoute == '/home',
                nextPageRoute: '/home',
              ),
              DrawerItem(
                title: 'Todo List',
                icon: Icons.list,
                isSelected: currentRoute == '/todo_list',
                nextPageRoute: '/todo_list',
              ),
              DrawerItem(
                title: 'Statistics',
                icon: Icons.auto_graph,
                isSelected: currentRoute == '/statistics',
                nextPageRoute: '/statistics',
              ),
              DrawerItem(
                title: 'Settings',
                icon: Icons.settings,
                isSelected: currentRoute == '/settings',
                nextPageRoute: '/settings',
              ),
            ]),
          ),
          ThemeFlipper(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Leave Household'),
            onTap: () => _leaveHousehold(context),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  void _leaveHousehold(BuildContext context) async {
    if (userService.householdId != null) {
      await userService.leaveHousehold();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/choose_household');
      }
    }
  }

  void _logout(BuildContext context) async {
    await userService.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
