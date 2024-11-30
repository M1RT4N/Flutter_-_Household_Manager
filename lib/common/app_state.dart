import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';

class AppState {
  final User? user;
  final Household? household;

  AppState({required this.user, required this.household});
}
