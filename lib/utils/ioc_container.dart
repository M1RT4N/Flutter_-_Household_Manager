import 'package:get_it/get_it.dart';
import 'package:household_manager/common/database_service.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/theme_controller.dart';
import 'package:household_manager/services/user_service.dart';

class IocContainer {
  static final GetIt getIt = GetIt.instance;

  static void setup() {
    getIt.registerLazySingleton<ThemeController>(() => ThemeController());
    getIt.registerSingleton(DatabaseService<User>('users',
        fromJson: User.fromJson, toJson: (user) => user.toJson()));
    getIt.registerSingleton(DatabaseService<Household>('households',
        fromJson: Household.fromJson,
        toJson: (household) => household.toJson()));
    getIt.registerSingleton(UserService(getIt<DatabaseService<User>>()));
    getIt.registerSingleton<HouseholdService>(HouseholdService(
        getIt<DatabaseService<Household>>(), getIt<UserService>()));
  }
}
