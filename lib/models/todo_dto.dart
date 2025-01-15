import 'package:household_manager/models/user.dart';

import 'todo.dart';

class TodoDto {
  final Todo todo;
  final User creator;
  final User assignee;
  final User? solver;

  TodoDto(
      {required this.todo,
      required this.creator,
      required this.assignee,
      this.solver});
}
