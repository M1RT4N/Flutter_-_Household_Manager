import 'package:flutter/material.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/widgets/todo_tile.dart';

const _topNBeforeDeadline = 5;
const _sectionPadding = 10.0;
const _sectionMarginVer = 1.0;
const _sectionMarginHor = 8.0;
const _sectionBubbleRadius = 8.0;

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
    final top5BeforeDeadline = _getTopNBeforeDeadline(appState.todos);
    final pastDeadline = _getPassedDeadline(appState.todos);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ..._buildSection(
            top5BeforeDeadline,
            'Top $_topNBeforeDeadline closest to deadline:',
            Theme.of(context).splashColor),
        ..._buildSection(
          pastDeadline,
          'Past deadline:',
          Theme.of(context).disabledColor,
        )
      ],
    );
  }

  List<Widget> _buildSection(
      List<Todo> todos, String sectionTitle, Color titleColor) {
    if (todos.isEmpty) {
      return [];
    }
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(_sectionPadding),
        margin: const EdgeInsets.symmetric(
          vertical: _sectionMarginVer,
          horizontal: _sectionMarginHor,
        ),
        decoration: BoxDecoration(
          color: titleColor,
          borderRadius: BorderRadius.all(Radius.circular(_sectionBubbleRadius)),
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ...todos.map((todo) => TodoTile(todo: todo)),
          ],
        ),
      ),
    ];
  }

  List<Todo> _getTopNBeforeDeadline(List<Todo> todos) {
    final todosCopy = List<Todo>.from(todos)
        .where((t) => DateTime.now().isBefore(t.deadline.toDate()))
        .toList();
    todosCopy.sort((t1, t2) => t1.deadline
        .toDate()
        .difference(DateTime.now())
        .compareTo(t2.deadline.toDate().difference(DateTime.now())));
    return todosCopy.take(_topNBeforeDeadline).toList();
  }

  List<Todo> _getPassedDeadline(List<Todo> todos) {
    return todos
        .where((t) => DateTime.now().isAfter(t.deadline.toDate()))
        .toList();
  }
}
