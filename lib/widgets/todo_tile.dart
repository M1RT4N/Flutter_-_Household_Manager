import 'package:flutter/material.dart';
import 'package:household_manager/models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.blue,
      ),
      child: Column(
        children: [
          Text(todo.id),
          Text(todo.createdById),
          Text(todo.description),
        ],
      ),
    );
  }
}
