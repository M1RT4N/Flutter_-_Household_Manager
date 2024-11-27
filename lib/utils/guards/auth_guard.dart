import 'package:flutter_modular/flutter_modular.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:household_manager/utils/routing/routes.dart';

class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: AppRoute.login.path);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    return FirebaseAuth.instance.currentUser != null;
  }
}
