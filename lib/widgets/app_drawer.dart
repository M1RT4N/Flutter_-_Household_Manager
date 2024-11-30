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
  final void Function(BuildContext) leaveHouseholdFunc;

  AppDrawer({
    super.key,
    required this.logoutFunc,
    required this.leaveHouseholdFunc,
  });

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
        Expanded(
          child: ListTile(
            leading: Icon(Icons.login_outlined),
            title: Text('Leave Household'),
            onTap: () => leaveHouseholdFunc(context),
          ),
        ),
      ],
    );
  }

// Widget _buildActionButtons(BuildContext context) {
//   return Row(
//     children: [
//       Expanded(
//           child: ListTile(
//         leading: Icon(Icons.logout),
//         title: Text('Logout'),
//         onTap: () async {
//           final confirm = await Utility.showConfirmationDialog(
//             context,
//             'Confirm Logout',
//             'Are you sure you want to logout?',
//           );
//           if (confirm == true && context.mounted) {
//             _logout(context);
//           }
//         },
//       )),
//       Expanded(
//           child: ListTile(
//         leading: Icon(Icons.login_outlined),
//         title: Text('Leave Household'),
//         onTap: () async {
//           final confirm = await Utility.showConfirmationDialog(
//             context,
//             'Confirm Leave Household',
//             'Are you sure you want to leave the household?',
//           );
//           if (confirm == true && context.mounted) {
//             _leaveHousehold(context);
//           }
//         },
//       )),
//     ],
//   );
// }
//
// void _leaveHousehold(BuildContext context) async {
//   if (_userService.getUser?.householdId == null) {
//     return;
//   }
//
//   final confirm = await Utility.showConfirmationDialog(
//     context,
//     'Confirm Leave',
//     'Are you sure you want to leave household?',
//   );
//
//   if (confirm != true) {
//     return;
//   }
//
//   String? errorMessage = await _householdService.tryLeaveHousehold();
//
//   if (context.mounted) {
//     if (errorMessage != null) {
//       return showTopSnackBar(
//           context, 'Failed to leave household: $errorMessage', Colors.red);
//     }
//     showTopSnackBar(context, 'Household left.', Colors.green);
//   }
//   Modular.to.navigate(AppRoute.chooseHousehold.route);
// }
//
// void _logout(BuildContext context) async {
//   if (_userService.getUser == null) {
//     return;
//   }
//
//   final confirm = await Utility.showConfirmationDialog(
//     context,
//     'Confirm Logout',
//     'Are you sure you want to logout?',
//   );
//
//   if (confirm != true) {
//     return;
//   }
//
//   await _userService.logout();
//   if (context.mounted) {
//     Modular.to.navigate(AppRoute.login.path);
//     showTopSnackBar(context, 'Logged out successfully.', Colors.green);
//   }
// }
}
