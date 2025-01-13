import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/utils/utility.dart';

const _maxWidth = 1000.0;
const _sectionPaddingHor = 16.0;
const _sectionMarginVer = 4.0;
const _sectionMarginHor = 16.0;
const _sectionBubbleRadius = 8.0;
const _importantTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
);
const _normalTextStyle = TextStyle(color: Colors.white70);
const _contentPadding = EdgeInsets.symmetric(
  horizontal: _sectionPaddingHor,
);
const _bubbleMargin = EdgeInsets.symmetric(
  horizontal: _sectionMarginHor,
  vertical: _sectionMarginVer,
);

class TodoTile extends StatelessWidget {
  final Todo todo;
  final User creator;
  final User assignee;
  final VoidCallback onClick;
  final bool showTickMark;

  const TodoTile(
      {super.key,
      required this.todo,
      required this.creator,
      required this.assignee,
      required this.onClick,
      this.showTickMark = false});

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
            Text(
              'Description: ',
              style: _normalTextStyle,
            ),
            Text(
              todo.description,
              style: _importantTextStyle,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Deadline: ', style: _normalTextStyle),
                Text(
                  Utility.formatDate(todo.deadline.toDate()),
                  style: _importantTextStyle,
                )
              ],
            ),
            Text(
              'Created by: ${creator.name}',
              style: _normalTextStyle,
            ),
            Text(
              'Created for: ${assignee.name}',
              style: _normalTextStyle,
            ),
            Text('Created at: ${Utility.formatDate(todo.createdAt.toDate())}',
                style: _normalTextStyle),
            if (todo.completedAt != null)
              Text(
                'Completed at: ${Utility.formatDate(todo.completedAt!.toDate())}',
                style: _normalTextStyle,
              ),
            if (todo.deletedAt != null)
              Text(
                'Deleted at: ${Utility.formatDate(todo.deletedAt!.toDate())}',
                style: _normalTextStyle,
              ),
          ],
        ),
        trailing: showTickMark
            ? IconButton(
                onPressed: () => _completeTodo(context, todo),
                icon: Icon(Icons.check),
              )
            : null,
      ),
    );
  }

  void _completeTodo(BuildContext context, Todo todo) async {
    final updatedTodo =
        todo.copyWith(completedAt: Timestamp.fromDate(DateTime.now()));
    await Utility.performActionAndShowInfo(
        context: context,
        action: () => GetIt.instance<TodoService>().updateTodo(updatedTodo),
        successMessage: 'Todo completed.');
  }
}
