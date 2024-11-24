import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:household_manager/pages/home_page.dart';
import 'package:household_manager/pages/login_page.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/widgets/snack_bar.dart';

import 'loading_screen.dart';

class AuthWrapper extends StatelessWidget {
  AuthWrapper({super.key});

  final UserService userService = IocContainer.getIt<UserService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.hasData) {
          return _buildUserProfile(context);
        }

        return LoginPage();
      },
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return FutureBuilder<void>(
      future: userService.fetchUserProfile(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (userSnapshot.hasError) {
          showTopSnackBar(context,
              'An error occurred while fetching user data.', Colors.red);
          return LoginPage();
        }

        if (userService.userProfile == null) {
          showTopSnackBar(context, 'User profile not found!', Colors.red);
          return LoginPage();
        }

        return HomePage();
      },
    );
  }
}
