import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/theme_flipper.dart';

const _breadcrumbPadding = 8.0;
const _initialsSize = 12.0;
const _initialsRadius = 16.0;
const _initialsRightPadding = 16.0;

const List<DrawerItem> _drawerItems = [
  DrawerItem(title: 'Household', icon: Icons.house, route: '/home'),
  DrawerItem(title: 'Todo List', icon: Icons.list, route: '/todo_list'),
  DrawerItem(title: 'Statistics', icon: Icons.auto_graph, route: '/statistics'),
  DrawerItem(title: 'Settings', icon: Icons.settings, route: '/settings'),
];

class DrawerItem {
  final String title;
  final IconData icon;
  final String route;

  const DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class LoginTemplate extends StatelessWidget {
  final String title;
  final List<String> breadcrumbPath;
  final Widget child;
  final String currentRoute;

  const LoginTemplate({
    Key? key,
    required this.title,
    required this.breadcrumbPath,
    required this.child,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: AppDrawer(currentRoute: currentRoute),
      body: Column(
        children: [
          _buildBreadcrumb(),
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
        Navigator.pushNamed(context, '/profile');
      },
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.all(_breadcrumbPadding),
      child: Row(
        children: breadcrumbPath.map((crumb) {
          int index = breadcrumbPath.indexOf(crumb);
          bool isLast = index == breadcrumbPath.length - 1;
          return Row(
            children: [
              Text(crumb),
              if (!isLast) Text(' > '),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getUserInitials() {
    final userService = GetIt.instance<UserService>();
    final userProfile = userService.userProfile;
    if (userProfile != null && userProfile.name.isNotEmpty) {
      return userProfile.name.trim().split(' ').map((e) => e[0]).take(2).join();
    }
    return '';
  }
}

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({
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
            child: ListView(
              children: _drawerItems
                  .map((item) => _buildDrawerItem(context, item))
                  .toList(),
            ),
          ),
          ThemeFlipper(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    bool isSelected = item.route == currentRoute;

    return _createDrawerItem(context, item, isSelected);
  }

  Widget _createDrawerItem(
      BuildContext context, DrawerItem item, bool isSelected) {
    return ListTile(
      leading: Icon(item.icon, color: isSelected ? Colors.blue : null),
      title: Text(
        item.title,
        style: TextStyle(
          color: isSelected ? Colors.blue : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (item.route == '/logout') {
          _logout();
        } else if (!isSelected) {
          Navigator.pushNamed(context, item.route);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // NOTE: Navigation should handle AuthWrapper
  }
}
