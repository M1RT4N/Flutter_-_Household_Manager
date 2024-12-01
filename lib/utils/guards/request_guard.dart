import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';

class RequestGuard extends RouteGuard {
  final _userService = GetIt.instance<UserService>();

  RequestGuard() : super(redirectTo: AppRoute.householdRequest.path);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    return _userService.getUser!.requestedId == null;
  }
}
