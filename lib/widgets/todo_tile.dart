import 'package:flutter/material.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/utils/utility.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created by: ${todo.id}'),
            Text('Description: ${todo.description}'),
            Text('Deadline: ${Utility.formatDate(todo.deadline.toDate())}'),
          ],
        ),
      ),
    );
  }
}
