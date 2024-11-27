import 'package:flutter_modular/flutter_modular.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard extends RouteGuard {
  AuthGuard() : super(redirectTo: '/login');

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    return FirebaseAuth.instance.currentUser != null;
  }
}
