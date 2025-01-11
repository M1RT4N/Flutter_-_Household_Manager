import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';

const _maxWidth = 1000.0;
const double _sectionPaddingHor = 16.0;
const double _sectionMarginVer = 4.0;
const double _sectionMarginHor = 16.0;
const double _sectionBubbleRadius = 8.0;
const _descriptionTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.white,
);
const _contentPadding = EdgeInsets.symmetric(
  horizontal: _sectionPaddingHor,
);
const _subtitleStyle = TextStyle(color: Colors.white70);
const _bubbleMargin = EdgeInsets.symmetric(
  horizontal: _sectionMarginHor,
  vertical: _sectionMarginVer,
);

class TodoTile extends StatelessWidget {
  final Todo todo;
  final User creator;
  final VoidCallback onClick;

  const TodoTile({
    super.key,
    required this.todo,
    required this.creator,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: _maxWidth),
      margin: _bubbleMargin,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        color: Colors.blue,
        borderRadius: BorderRadius.circular(_sectionBubbleRadius),
      ),
      child: ListTile(
        onTap: onClick,
        contentPadding: _contentPadding,
        title: Wrap(
          children: [
            Text('Description: '),
            Text(
              todo.description,
              style: _descriptionTextStyle,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created by: ${GetIt.instance<UserService>().getUser!.id == creator.id ? 'You' : creator.name}',
              style: _subtitleStyle,
            ),
            Text('Deadline: ${Utility.formatDate(todo.deadline.toDate())}',
                style: _subtitleStyle),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _completeTodo(context, todo),
          icon: Icon(Icons.check),
        ),
      ),
    );
  }

  void _completeTodo(BuildContext context, Todo todo) async {
    final updatedTodo =
        todo.copyWith(completedAt: Timestamp.fromDate(DateTime.now()));
    Utility.performActionAndShowInfo(
        context: context,
        action: () => GetIt.instance<TodoService>().updateTodo(updatedTodo),
        successMessage: 'Todo completed.');
  }
}
