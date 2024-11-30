import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';

class UserGuard extends RouteGuard {
  final _userService = GetIt.instance<UserService>();

  UserGuard() : super(redirectTo: AppRoute.login.path);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    // FirebaseAuth.instance.signOut();
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    if (_userService.getUser != null) {
      return true;
    }

    return await _userService.fetchUser(user.uid) != null;
  }
}
