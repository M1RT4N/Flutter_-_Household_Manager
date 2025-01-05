import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/widgets/todo_tile.dart';

const _topNBeforeDeadline = 5;
const _sectionBubbleRadius = 8.0;
const _sectionTitleStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 18,
);
const _sectionPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 0);
const _sectionMargin = EdgeInsets.symmetric(
  vertical: 2,
  horizontal: 12,
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Home',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context) {
    return LoadingStreamBuilder(
      stream: GetIt.instance<TodoService>().getTodoStream,
      builder: (context, snapshot) {
        var todos = snapshot as List<Todo>;
        // TODO here is something wrong - infinite loop
        final top5BeforeDeadline = _getTopNBeforeDeadline(todos);
        final pastDeadline = _getPassedDeadline(todos);

        return ListView(
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
      },
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
        padding: _sectionPadding,
        margin: _sectionMargin,
        decoration: BoxDecoration(
          color: titleColor,
          borderRadius: BorderRadius.all(Radius.circular(_sectionBubbleRadius)),
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionTitle,
              style: _sectionTitleStyle,
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
