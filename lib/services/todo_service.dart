import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/services/database_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';

const _todoIdLength = 28;

class TodoService {
  final UserService _userService;
  final DatabaseService<Todo> _todoRepository;

  TodoService(this._todoRepository, this._userService);

  Stream<List<Todo>> get getTodoStream {
    final userId = _userService.getUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }
    return _todoRepository.reference
        .snapshots()
        .map((snapShot) => snapShot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Todo>> getTodoStreamTopNBeforeDeadline() {
    return getTodoStream.map((todos) {
      return todos
          .where((t) =>
              DateTime.now().isBefore(t.deadline.toDate()) &&
              t.completedAt == null &&
              t.deletedAt == null)
          .toList()
        ..sort((t1, t2) => t1.deadline
            .toDate()
            .difference(DateTime.now())
            .compareTo(t2.deadline.toDate().difference(DateTime.now())));
    });
  }

  Future<Todo> createTodo(String createdForId, DateTime deadline,
      String description, String title, String householdId) async {
    final todo = Todo(
      id: Utility.generateRandomCode(_todoIdLength),
      createdById: _userService.getUser!.id,
      createdForId: createdForId,
      createdAt: Timestamp.now(),
      deadline: Timestamp.fromDate(deadline),
      description: description,
      title: title,
      householdId: householdId,
    );

    await _todoRepository.setOrAdd(todo.id, todo);

    return todo;
  }

  Future<String?> updateTodo(Todo updateTodo) async {
    _todoRepository.setOrAdd(updateTodo.id, updateTodo);
    return null;
  }

  Future<List<TodoDto>> fetchUsers(List<Todo> todos) async {
    final res = await Future.wait([
      _userService.getUsersByIds(
        todos.map((t) => t.createdById).toList(),
      ),
      _userService.getUsersByIds(
        todos.map((t) => t.createdForId).toList(),
      )
    ]);

    final creators = res[0];
    final assignees = res[1];

    final List<TodoDto> todosWithUsers = [];
    for (final todo in todos) {
      todosWithUsers.add(TodoDto(
          todo: todo,
          creator: creators.firstWhere((c) => c.id == todo.createdById),
          assignee: assignees.firstWhere((c) => c.id == todo.createdForId)));
    }

    return todosWithUsers;
  }

  Stream<List<Todo>> getTodoStreamAll(List<String> userIds) {
    return getTodoStream.map((todos) {
      return todos
          .where((t) => userIds.contains(t.createdForId) && t.deletedAt == null)
          .toList()
        ..sort((t1, t2) => t1.deadline.compareTo(t2.deadline));
    });
  }
}
