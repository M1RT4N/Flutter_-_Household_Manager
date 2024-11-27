import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/drawer_item.dart';
import 'package:household_manager/widgets/theme_flipper.dart';

const _logoPath = 'assets/icons/logo.svg';
const _drawerInnerPadding = 16.0;
const _logoLeftPadding = 16.0;
const _logoHeight = 256.0;
const _logoWidth = 512.0;
const _themeSwitcherPadding = 8.0;
const _themeSwitcherPaddingInnerRight = 24.0;

class AppDrawer extends StatelessWidget {
  final drawerItems = [
    {
      'title': 'Home',
      'icon': Icons.house_outlined,
      'route': AppRoute.home.path
    },
    {
      'title': 'Statistics',
      'icon': Icons.auto_graph,
      'route': AppRoute.statistics.path
    },
    {
      'title': 'Household Members',
      'icon': Icons.person_2_outlined,
      'route': AppRoute.members.path,
    },
    {},
    {
      'title': 'Todo List',
      'icon': Icons.list,
      'route': AppRoute.todos.path,
    },
    {'title': 'New Todo', 'icon': Icons.add, 'route': AppRoute.createTodo.path},
    {},
    {
      'title': 'Settings',
      'icon': Icons.settings,
      'route': AppRoute.settings.path
    },
  ];

  final userService = GetIt.instance<UserService>();

  AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: _drawerInnerPadding),
        child: Column(
          children: [
            _buildDrawerHeader(context),
            _buildDrawerList(),
            _buildActionButtons(context),
            const Divider(),
            _buildThemeSwitcher(),
          ],
        ),
      ),
    );
  }

// TODO: Fix this, it should work... WTF
// https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
  Widget _buildDrawerHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Modular.to.navigate(AppRoute.home.path);
      },
      child: DrawerHeader(
        padding: EdgeInsets.only(left: _logoLeftPadding),
        child: SvgPicture.asset(
          _logoPath,
          width: _logoWidth,
          height: _logoHeight,
        ),
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
      padding: const EdgeInsets.only(right: _themeSwitcherPadding),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Padding(
                    padding:
                        EdgeInsets.only(right: _themeSwitcherPaddingInnerRight),
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
    if (userService.householdId == null) {
      return;
    }

    await userService.leaveHousehold();

    if (context.mounted) {
      Modular.to.navigate(AppRoute.chooseHousehold.path);
    }
  }
}
