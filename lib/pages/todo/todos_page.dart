import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/filters/stat_range.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/tabs/todo_section.dart';
import 'package:household_manager/widgets/info_bubble.dart';
import 'package:household_manager/widgets/navigation_header.dart';
import 'package:household_manager/widgets/todo_tile.dart';

const _buttonPadding = EdgeInsets.all(12.0);
const _buttonBorderRadius = 24.0;
const _mediaQueryLimit = 600.0;
const _widthFactorWeb = 0.6;
const _headerHeight = 125.0;

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final userService = GetIt.instance<UserService>();

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate<List<Todo>>(
      title: 'TODOs',
      stream: GetIt.instance<TodoService>().getTodoStream,
      bodyFunction: _buildBodyCommon,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBodyCommon(BuildContext context, List<Todo> todos) {
    return Center(
      child: NavigationHeader<TodoSectionEnum>(
        values: TodoSectionEnum.values,
        selectionCallback: (TodoSectionEnum s) =>
            renderSelectedContent(s, todos),
      ),
    );
  }

  Widget _buildSection(List<TodoDto> todosWithUsers) {
    if (todosWithUsers.isEmpty) {
      return InfoBubble(labelText: 'No todos found for this section');
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width > _mediaQueryLimit
          ? MediaQuery.of(context).size.width * _widthFactorWeb
          : MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - _headerHeight,
      child: ListView(
        children: [
          for (final todoWithUsers in todosWithUsers)
            TodoTile(
              todo: todoWithUsers.todo,
              creator: todoWithUsers.creator,
              assignee: todoWithUsers.assignee,
              solver: todoWithUsers.solver,
              showTickMark: todoWithUsers.todo.completedAt == null &&
                  todoWithUsers.todo.deletedAt == null,
              onClick: () => Modular.to.pushNamed(
                AppRoute.editTodo.path,
                arguments: todoWithUsers,
              ),
            ),
        ],
      ),
    );
  }

  Widget renderSelectedContent(TodoSectionEnum section, List<Todo> todos) {
    TodoSection? selectedSection = TodoSectionEnum.getSectionInstance(section);

    return LoadingFutureBuilder(
        future: GetIt.instance<TodoService>().fetchUsers(selectedSection == null
            ? todos
            : selectedSection.filter(
                todos, userService.getUser!, StatRange.AllTime)),
        builder: (context, todosWithUsers) {
          return _buildSection(todosWithUsers);
        });
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () => Modular.to.pushNamed(AppRoute.editTodo.route),
        icon: const Icon(Icons.add),
        label: const Text('Create TODO'),
        style: ElevatedButton.styleFrom(
          padding: _buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
        ),
      ),
    );
  }
}
