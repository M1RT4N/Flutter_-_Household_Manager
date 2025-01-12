import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/enums/todo_section.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/services/database_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

const _todoIdLength = 28;

class TodoService {
  final UserService _userService;
  final DatabaseService<Todo> _todoRepository;
  final _filterController =
      BehaviorSubject<TodoSection>.seeded(TodoSection.Active);

  TodoService(this._todoRepository, this._userService);

  Stream<List<Todo>> get _getTodoStream {
    final userId = _userService.getUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }
    return _todoRepository.reference
        .snapshots()
        .map((snapShot) => snapShot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Todo>> getTodoStreamTopNBeforeDeadline(int n) {
    return _getTodoStream.map((todos) {
      return todos
          .where((t) =>
              DateTime.now().isBefore(t.deadline.toDate()) &&
              t.createdForId == _userService.getUser!.id &&
              t.completedAt == null &&
              t.deletedAt == null)
          .toList()
        ..sort((t1, t2) => t1.deadline
            .toDate()
            .difference(DateTime.now())
            .compareTo(t2.deadline.toDate().difference(DateTime.now())))
        ..take(n);
    });
  }

  Stream<List<Todo>> get getTodoStreamSectionFiltered {
    final userId = _userService.getUser!.id;

    return _getTodoStream.map((todos) {
      switch (_filterController.value) {
        case TodoSection.Active:
          return todos
              .where((t) =>
                  t.createdForId == userId &&
                  t.completedAt == null &&
                  t.deletedAt == null)
              .toList()
            ..sort((t1, t2) => t1.deadline.compareTo(t2.deadline));
        case TodoSection.Done:
          return todos
              .where((t) =>
                  t.createdForId == userId &&
                  t.completedAt != null &&
                  t.deletedAt == null)
              .toList()
            ..sort((t1, t2) => t1.completedAt!.compareTo(t2.completedAt!));
        case TodoSection.Created:
          return todos
              .where((t) =>
                  t.createdById == userId &&
                  t.deletedAt == null &&
                  t.completedAt == null)
              .toList()
            ..sort((t1, t2) => t1.createdAt.compareTo(t2.createdAt));
        case TodoSection.Deleted:
          return todos
              .where((t) =>
                  t.createdById == userId &&
                  t.completedAt == null &&
                  t.deletedAt != null)
              .toList()
            ..sort((t1, t2) => t1.deletedAt!.compareTo(t2.deletedAt!));
        default:
          return [];
      }
    });
  }

  Future<Todo> createTodo(
      String createdForId, DateTime deadline, String description) async {
    final todo = Todo(
      id: Utility.generateRandomCode(_todoIdLength),
      createdById: _userService.getUser!.id,
      createdForId: createdForId,
      createdAt: Timestamp.now(),
      deadline: Timestamp.fromDate(deadline),
      description: description,
    );

    await _todoRepository.setOrAdd(todo.id, todo);

    return todo;
  }

  Future<void> updateTodo(Todo updateTodo) async {
    _todoRepository.setOrAdd(updateTodo.id, updateTodo);
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

  void setSectionFilter(TodoSection section) {
    _filterController.value = section;
  }
}
