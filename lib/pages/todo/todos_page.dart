import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/todo_tile.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'My TODOs',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context) {
    return LoadingStreamBuilder(
      stream: GetIt.instance<TodoService>().getTodoStream,
      builder: (context, todos) {
        return Center(
          child: ListView(
            children: [
              if (todos != null) ...[
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
      },
    );
  }
}
