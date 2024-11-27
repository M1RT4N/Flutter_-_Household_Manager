import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/utils/routing/routes.dart';

class AppModule extends Module {
  @override
  final List<ModularRoute> routes = AppRoute.values.map((route) {
    return ChildRoute(route.path,
        child: (_, __) => route.pageType, guards: route.guards);
  }).toList();
}
