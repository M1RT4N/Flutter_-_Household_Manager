import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';

class HouseholdGuard extends RouteGuard {
  final _userService = GetIt.instance<UserService>();
  final _householdService = GetIt.instance<HouseholdService>();

  HouseholdGuard() : super(redirectTo: AppRoute.chooseHousehold.route);

  @override
  Future<bool> canActivate(String path, ModularRoute route) async {
    if (_householdService.getHousehold != null) {
      return true;
    }

    var user = _userService.getUser!;
    if (user.requestedId != null || user.householdId == null) {
      return false;
    }

    return await _householdService.fetchHousehold(user.householdId!) != null;
  }
}
