import 'package:household_manager/models/user.dart';

import 'todo.dart';

class TodoDto {
  final Todo todo;
  final User creator;

  TodoDto({
    required this.todo,
    required this.creator,
  });
}
