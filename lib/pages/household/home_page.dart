import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
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
    return LoadingPageTemplate<List<Todo>>(
      title: 'Home',
      stream: GetIt.instance<TodoService>().getTodoStream,
      bodyFunctionPhone: _buildBody,
      bodyFunctionWeb: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, List<Todo> todos) {
    final top5BeforeDeadline = _getTopNBeforeDeadline(todos);
    final pastDeadline = _getPassedDeadline(todos);
    final userService = GetIt.instance<UserService>();

    return LoadingFutureBuilder(
        future: Future.wait([
          userService.getUsersByIds(
              top5BeforeDeadline.map((t) => t.createdById).toList()),
          userService
              .getUsersByIds(pastDeadline.map((t) => t.createdById).toList()),
        ]),
        builder: (context, result) {
          final top5Creators = result[0];
          final pastDeadlineCreators = result[1];
          return Column(
            children: [
              if (top5BeforeDeadline.isNotEmpty)
                _buildSection(
                  context,
                  top5BeforeDeadline,
                  top5Creators,
                  'Top $_topNBeforeDeadline closest to deadline:',
                  Theme.of(context).splashColor,
                ),
              if (pastDeadline.isNotEmpty)
                _buildSection(
                  context,
                  pastDeadline,
                  pastDeadlineCreators,
                  'Past deadline:',
                  Theme.of(context).disabledColor,
                ),
            ],
          );
        });
  }

  Widget _buildSection(BuildContext context, List<Todo> todos,
      List<User> creators, String sectionTitle, Color titleColor) {
    return Container(
        width: double.infinity,
        padding: _sectionPadding,
        margin: _sectionMargin,
        decoration: BoxDecoration(
          color: titleColor,
          borderRadius: BorderRadius.all(Radius.circular(_sectionBubbleRadius)),
        ),
        child: Column(
          children: [
            Text(
              sectionTitle,
              style: _sectionTitleStyle,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                final creator =
                    creators.firstWhere((c) => c.id == todo.createdById);
                return TodoTile(
                  todo: todo,
                  creator: creator,
                  onClick: () => Modular.to.pushNamed(
                    AppRoute.editTodo.path,
                    arguments: [todo, creator],
                  ),
                );
              },
            ),
          ],
        ));
  }
}

List<Todo> _getTopNBeforeDeadline(List<Todo> todos) {
  final todosCopy = List<Todo>.from(todos)
      .where((t) =>
          DateTime.now().isBefore(t.deadline.toDate()) &&
          t.completedAt == null &&
          t.deletedAt == null)
      .toList();
  todosCopy.sort((t1, t2) => t1.deadline
      .toDate()
      .difference(DateTime.now())
      .compareTo(t2.deadline.toDate().difference(DateTime.now())));
  return todosCopy.take(_topNBeforeDeadline).toList();
}

List<Todo> _getPassedDeadline(List<Todo> todos) {
  return todos
      .where((t) =>
          DateTime.now().isAfter(t.deadline.toDate()) &&
          t.completedAt == null &&
          t.deletedAt == null)
      .toList();
}
