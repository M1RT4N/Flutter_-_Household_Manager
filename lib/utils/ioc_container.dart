import 'package:get_it/get_it.dart';
import 'package:household_manager/services/theme_controller.dart';
import 'package:household_manager/services/user_service.dart';

class IocContainer {
  static final GetIt getIt = GetIt.instance;

  static void setup() {
    getIt.registerLazySingleton<ThemeController>(() => ThemeController());
    getIt.registerLazySingleton<UserService>(() => UserService());

    // Here add other services
  }
}
