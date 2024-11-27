import 'package:flutter/material.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/widgets/app_drawer.dart';

// const _breadcrumbPadding = 8.0;
const _initialsSize = 12.0;
const _initialsRadius = 16.0;
const _initialsRightPadding = 16.0;

class PageTemplate extends StatelessWidget {
  final String title;
  final Widget child;
  final String currentRoute;
  final User user;
  final Household household;

  PageTemplate({
    Key? key,
    required this.title,
    required this.child,
    required this.currentRoute,
    required this.user,
    required this.household,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   if (!userService.isLoggedIn) {
    //     return; // Not logged in
    //   }
    //   await userService.fetchUserProfile();
    //   if (userService.householdId == null && context.mounted) {
    //     Navigator.pushReplacementNamed(context, '/choose_household');
    //   }
    // });

    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: AppDrawer(currentRoute: currentRoute),
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
        Navigator.pushNamed(context, '/profile');
      },
    );
  }

  // Widget _buildBreadcrumb() {
  //   return Container(
  //     color: Colors.grey,
  //     padding: const EdgeInsets.all(_breadcrumbPadding),
  //     child: Row(
  //       children: breadcrumbPath.map((crumb) {
  //         int index = breadcrumbPath.indexOf(crumb);
  //         bool isLast = index == breadcrumbPath.length - 1;
  //         return Row(
  //           children: [
  //             Text(crumb),
  //             if (!isLast) Text(' > '),
  //           ],
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  String _getUserInitials() {
    return user.name.trim().split(' ').map((e) => e[0]).take(2).join();
  }
}
