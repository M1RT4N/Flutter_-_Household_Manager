import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/pages/auth/login_page.dart';
import 'package:household_manager/pages/household_page.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/ioc_container.dart';
import 'package:household_manager/widgets/snackbar.dart';
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
        ProfileInfo profileInfo = userService.getUserProfile();
        return HomePage(profileInfo: profileInfo);
      },
    );
  }
}
