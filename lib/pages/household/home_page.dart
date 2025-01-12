import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/todo_service.dart';
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
      stream: GetIt.instance<TodoService>()
          .getTodoStreamTopNBeforeDeadline(_topNBeforeDeadline),
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
    );
  }

  // TODO: implement or use phone design
  Widget _buildBodyWeb(BuildContext context, List<Todo> topNBeforeDeadline) {
    return _buildBodyPhone(context, topNBeforeDeadline);
  }

  Widget _buildBodyPhone(BuildContext context, List<Todo> topNBeforeDeadline) {
    return LoadingFutureBuilder(
      future: GetIt.instance<TodoService>().fetchUsers(topNBeforeDeadline),
      builder: (context, topNWithUsers) {
        return SingleChildScrollView(
          // Wrap the column in a SingleChildScrollView
          child: Column(
            children: [
              if (topNBeforeDeadline.isNotEmpty)
                _buildSection(
                  context,
                  topNWithUsers,
                  'Top $_topNBeforeDeadline closest to deadline:',
                  Theme.of(context).splashColor,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, List<TodoDto> todosWithUsers,
      String sectionTitle, Color titleColor) {
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
              itemCount: todosWithUsers.length,
              itemBuilder: (context, index) {
                final todoWithUsers = todosWithUsers[index];
                return TodoTile(
                  todo: todoWithUsers.todo,
                  creator: todoWithUsers.creator,
                  assignee: todoWithUsers.assignee,
                  showTickMark: true,
                  onClick: () => Modular.to.pushNamed(
                    AppRoute.editTodo.path,
                    arguments: todoWithUsers,
                  ),
                );
              },
            ),
          ],
        ));
  }
}
