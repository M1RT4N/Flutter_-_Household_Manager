import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/drawer_item.dart';
import 'package:household_manager/widgets/theme_flipper.dart';

class AppDrawer extends StatelessWidget {
  final drawerItems = [
    {'title': 'Home', 'icon': Icons.house_outlined, 'route': '/home'},
    {'title': 'Statistics', 'icon': Icons.auto_graph, 'route': '/statistics'},
    {
      'title': 'Household Members',
      'icon': Icons.person_2_outlined,
      'route': '/members'
    },
    {},
    {'title': 'Todo List', 'icon': Icons.list, 'route': '/todo_list'},
    {'title': 'New Todo', 'icon': Icons.add, 'route': '/new_todo'},
    {},
    {'title': 'Settings', 'icon': Icons.settings, 'route': '/settings'},
  ];

  final userService = GetIt.instance<UserService>();

  AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          children: [
            _buildDrawerHeader(),
            _buildDrawerList(),
            _buildActionButtons(context),
            const Divider(),
            _buildThemeSwitcher(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      padding: EdgeInsets.only(left: 16.0),
      child: SvgPicture.asset(
        'assets/icons/logo.svg',
        width: 512,
        height: 256,
      ),
    );
  }

  Widget _buildDrawerList() {
    return Expanded(
      child: ListView(
        children: drawerItems.map((item) {
          if (item.isEmpty) {
            return Divider();
          }
          return DrawerItem(
            title: item['title']! as String,
            icon: item['icon'] as IconData,
            nextPageRoute: item['route'] as String,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              final confirm = await showConfirmationDialog(
                context,
                'Confirm Logout',
                'Are you sure you want to logout?',
              );
              if (confirm == true && context.mounted) {
                logout(context, userService);
              }
            },
          ),
        ),
        Expanded(
          child: ListTile(
            leading: Icon(Icons.cancel_outlined),
            title: Text('Leave Household'),
            onTap: () async {
              final confirm = await showConfirmationDialog(
                context,
                'Confirm Leave Household',
                'Are you sure you want to leave the household?',
              );
              if (confirm == true && context.mounted) {
                _leaveHousehold(context);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSwitcher() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(right: 24.0),
                    child: Icon(Icons.brush)),
                Text('Current theme'),
              ],
            ),
            ThemeFlipper(),
          ],
        ),
      ),
    );
  }

  void _leaveHousehold(BuildContext context) async {
    if (userService.householdId != null) {
      await userService.leaveHousehold();

      if (context.mounted) {
        Modular.to.navigate('/choose_household');
      }
    }
  }
}
