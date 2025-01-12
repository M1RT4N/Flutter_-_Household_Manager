import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/enums/todo_section.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/todo_tile.dart';

const _buttonPadding = EdgeInsets.all(12.0);
const _buttonBorderRadius = 24.0;
const _verticalGap = SizedBox(height: 12);
const _sectionButtonsBorder = BoxDecoration(
  border: Border(
    bottom: BorderSide(color: Colors.grey, width: 1),
    left: BorderSide(color: Colors.grey, width: 1),
  ),
);
const _sectionButtonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.zero,
);
const _sectionButtonPadding = EdgeInsets.all(16);
const _sectionButtonOpacity = 0.2;

class MyTodosPage extends StatefulWidget {
  const MyTodosPage({super.key});

  @override
  State<MyTodosPage> createState() => _MyTodosPageState();
}

class _MyTodosPageState extends State<MyTodosPage> {
  TodoSection _selectedSection = TodoSection.values.first;
  final _todoService = GetIt.instance<TodoService>();

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate<List<Todo>>(
      title: 'My TODOs',
      stream: GetIt.instance<TodoService>().getTodoStreamSectionFiltered,
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // TODO: implement or use the same design as is for phone
  Widget _buildBodyWeb(BuildContext context, List<Todo> todos) {
    return _buildBodyPhone(context, todos);
  }

  Widget _buildBodyPhone(BuildContext context, List<Todo> todos) {
    return LoadingFutureBuilder(
        future: GetIt.instance<TodoService>().fetchUsers(todos),
        builder: (context, todosWithUsers) {
          return Column(
            children: [
              _buildSectionButtons(),
              _verticalGap,
              _buildSection(todosWithUsers),
            ],
          );
        });
  }

  Widget _buildSection(List<TodoDto> todosWithUsers) {
    if (todosWithUsers.isEmpty) {
      return Center(child: Text('No todos found for this section'));
    }
    return Expanded(
      child: ListView(
        children: [
          for (final todoWithUsers in todosWithUsers)
            TodoTile(
              todo: todoWithUsers.todo,
              creator: todoWithUsers.creator,
              assignee: todoWithUsers.assignee,
              showTickMark: _selectedSection == TodoSection.Active,
              onClick: () => Modular.to.pushNamed(
                AppRoute.editTodo.path,
                arguments: todoWithUsers,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionButtons() {
    return Container(
      decoration: _sectionButtonsBorder,
      child: Row(
        children: [
          for (final section in TodoSection.values)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey)),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: _sectionButtonShape,
                    padding: _sectionButtonPadding,
                    backgroundColor: section == _selectedSection
                        ? Colors.blue.withOpacity(_sectionButtonOpacity)
                        : Colors.transparent,
                  ),
                  onPressed: () => setState(() {
                    _todoService.setSectionFilter(section);
                    _selectedSection = section;
                  }),
                  child: Text(
                    Utility.getStringFromEnum(section),
                    style: TextStyle(
                      color: section == _selectedSection ? Colors.blue : null,
                      fontWeight: section == _selectedSection
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
