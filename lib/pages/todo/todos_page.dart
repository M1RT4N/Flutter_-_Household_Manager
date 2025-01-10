import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/todo_tile.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate(
      title: 'My TODOs',
      stream: GetIt.instance<TodoService>().getTodoStream,
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
    );
  }

  // TODO: implement
  Widget _buildBodyWeb(BuildContext context, List<Todo> todos) {
    return Container();
  }

  Widget _buildBodyPhone(BuildContext context, List<Todo> todos) {
    return Center(
      child: ListView(
        children: [
          if (todos.isNotEmpty) ...[
            for (final todo in todos as Iterable) TodoTile(todo: todo)
          ],
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Create TODO'),
            onTap: () => Modular.to.pushNamed(AppRoute.createTodo.route),
          ),
        ],
      ),
    );
  }
}
