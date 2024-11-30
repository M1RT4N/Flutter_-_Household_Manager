import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/loading_screen.dart';

final _userService = GetIt.instance<UserService>();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen();
  }

  Future<void> _checkAuth() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _userService.fetchUser(user.uid);
      return Modular.to.navigate(AppRoute.home.path);
    }
    Modular.to.navigate(AppRoute.login.path);
  }
}
