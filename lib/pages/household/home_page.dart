import 'package:flutter/material.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/widgets/todo_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Home',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    final top5BeforeDeadline = _getTop5BeforeDeadline(appState.todos);
    final pastDeadline = _getPassedDeadline(appState.todos);

    return Column(
      children: [
        ..._buildSection(top5BeforeDeadline, 'Top 5 closest to deadline'),
        ..._buildSection(pastDeadline, 'Past deadline')
      ],
    );
  }

  List<Widget> _buildSection(List<Todo> todos, String sectionTitle) {
    if (todos.isNotEmpty) {
      return [
        Text(sectionTitle),
        Expanded(
          child: ListView(
            children: [
              for (final todo in todos) TodoTile(todo: todo),
            ],
          ),
        ),
      ];
    }
    return [];
  }

  List<Todo> _getTop5BeforeDeadline(List<Todo> todos) {
    final todosCopy = List<Todo>.from(todos)
        .where((t) => DateTime.now().isBefore(t.deadline.toDate()))
        .toList();
    todosCopy.sort((t1, t2) => t1.deadline
        .toDate()
        .difference(DateTime.now())
        .compareTo(t2.deadline.toDate().difference(DateTime.now())));
    return todosCopy.take(5).toList();
  }

  List<Todo> _getPassedDeadline(List<Todo> todos) {
    return todos
        .where((t) => DateTime.now().isAfter(t.deadline.toDate()))
        .toList();
  }
}
