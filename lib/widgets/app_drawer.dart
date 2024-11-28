import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/drawer_item.dart';
import 'package:household_manager/widgets/theme_flipper.dart';

class AppDrawer extends StatelessWidget {
  final userService = GetIt.instance<UserService>();

  AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerItems = [
      {'title': 'Household', 'icon': Icons.house, 'route': '/home'},
      {'title': 'Todo List', 'icon': Icons.list, 'route': '/todo_list'},
      {'title': 'Statistics', 'icon': Icons.auto_graph, 'route': '/statistics'},
      {'title': 'Settings', 'icon': Icons.settings, 'route': '/settings'},
    ];

    return Drawer(
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/logo.svg',
            width: 400,
            height: 200,
          ),
          Expanded(
            child: ListView(
              children: drawerItems.map((item) {
                return DrawerItem(
                  title: item['title']! as String,
                  icon: item['icon'] as IconData,
                  nextPageRoute: item['route'] as String,
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Current theme'),
                  ThemeFlipper(),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Leave Household'),
            onTap: () => _leaveHousehold(context),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => logout(context, userService),
          ),
        ],
      ),
    );
  }

  void _leaveHousehold(BuildContext context) async {
    if (userService.getUser?.householdId != null) {
      // await userService.leaveHousehold();

      if (context.mounted) {
        Modular.to.navigate('/choose_household');
      }
    }
  }
}
