import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/todo.dart';
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
        .where('createdForId', isEqualTo: userId)
        .snapshots()
        .map((snapShot) => snapShot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> create(
      String createdForId, Timestamp deadline, String description) async {
    final todo = Todo(
      id: Utility.generateRandomCode(_todoIdLength),
      createdById: _userService.getUser!.id,
      createdForId: createdForId,
      createdAt: Timestamp.now(),
      deadline: deadline,
      description: description,
    );

    await _todoRepository.setOrAdd(todo.id, todo);
  }

  Future<void> updateTodo(Todo updateTodo) async {
    _todoRepository.setOrAdd(updateTodo.id, updateTodo);
  }
}
