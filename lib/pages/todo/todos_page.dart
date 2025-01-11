import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/todo_tile.dart';
import 'package:rxdart/rxdart.dart';

const _buttonPadding = EdgeInsets.all(12.0);
const _buttonBorderRadius = 24.0;

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate<List<Todo>>(
      title: 'My TODOs',
      stream: GetIt.instance<TodoService>()
          .getTodoStream
          .switchMap((l) => Stream.value(
                l
                    .where((t) => t.deletedAt == null && t.completedAt == null)
                    .toList(),
              )),
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // TODO: implement or use the same design as is for phone
  Widget _buildBodyWeb(BuildContext context, List<Todo> todos) {
    return Container();
  }

  Widget _buildBodyPhone(BuildContext context, List<Todo> todos) {
    return LoadingFutureBuilder(
        future: GetIt.instance<UserService>()
            .getUsersByIds(todos.map((t) => t.createdById).toList()),
        builder: (context, creators) {
          return Center(
            child: ListView(
              children: [
                if (todos.isNotEmpty) ...[
                  for (final todo in todos)
                    TodoTile(
                      todo: todo,
                      creator:
                          creators.firstWhere((c) => c.id == todo.createdById),
                      onClick: () => Modular.to
                          .pushNamed(AppRoute.editTodo.path, arguments: [
                        todo,
                        creators.firstWhere((c) => c.id == todo.createdById)
                      ]),
                    )
                ],
              ],
            ),
          );
        });
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () => Modular.to.pushNamed(AppRoute.createTodo.route),
        icon: const Icon(Icons.add),
        label: const Text('Create TODO'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonBorderRadius),
          ),
          padding: _buttonPadding,
        ),
      ),
    );
  }
}
