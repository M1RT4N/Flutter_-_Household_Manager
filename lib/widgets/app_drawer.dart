import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:household_manager/utils/routing/routes.dart';
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
  final void Function(BuildContext) logoutFunc;

  AppDrawer({
    super.key,
    required this.logoutFunc,
  });

  final drawerItems = [
    {
      'title': 'Home',
      'icon': Icons.house_outlined,
      'route': AppRoute.home.path
    },
    {
      'title': 'Household',
      'icon': Icons.person_2_outlined,
      'route': AppRoute.household.path,
    },
    {
      'title': 'TODOs',
      'icon': Icons.list,
      'route': AppRoute.todos.path,
    },
    {
      'title': 'Statistics',
      'icon': Icons.auto_graph,
      'route': AppRoute.statistics.path
    },
  ];

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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => logoutFunc(context),
          ),
        ),
      ],
    );
  }
}
