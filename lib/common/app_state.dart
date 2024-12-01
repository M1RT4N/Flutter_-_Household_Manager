import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';

class AppState {
  final User? user;
  final Household? household;
  final List<Todo> todos;

  AppState({
    required this.user,
    required this.household,
    required this.todos,
  });
}
