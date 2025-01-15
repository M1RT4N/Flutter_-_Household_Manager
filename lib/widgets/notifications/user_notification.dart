import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/models/user.dart' as models;
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';

import 'base_notification.dart';

const _contentActionGap = 30.0;
const _iconRightPadding = 12.0;

class UserNotification extends BaseNotification {
  final models.Notification notification;

  final _userService = GetIt.instance<UserService>();

  UserNotification({required this.notification})
      : super(
          title: notification.title,
          description: notification.description,
          icon: notification.type.getIcon(),
        );

  @override
  Widget build(BuildContext context) {
    return LoadingStreamBuilder(
        stream: GetIt.instance<TodoService>().getTodoStream,
        builder: (context, todos) {
          var filteredTodos = todos.where((t) {
            return t.id == notification.link;
          }).toList();

          if (filteredTodos.isEmpty) {
            return _buildTileContent(context, null);
          }

          return LoadingFutureBuilder(
              future: GetIt.instance<TodoService>().fetchUsers(filteredTodos),
              builder: (context, todoWithUser) {
                return _buildTileContent(context, todoWithUser.first);
              });
        });
  }

  Widget _buildTileContent(BuildContext context, TodoDto? todoWithUser) {
    return Row(
      children: [
        buildIcon(),
        SizedBox(width: _iconRightPadding),
        buildContent(
            onTitleClick: (todoWithUser == null)
                ? null
                : () => onTitleClick(todoWithUser)),
        SizedBox(width: _contentActionGap),
        buildAction(context),
      ],
    );
  }

  void onTitleClick(TodoDto todoWithUser) {
    Modular.to.pushNamed(AppRoute.editTodo.path, arguments: todoWithUser);
  }

  @override
  Widget buildAction(BuildContext context) {
    if (notification.isHidden) {
      return SizedBox.shrink();
    }
    return IconButton(
      onPressed: () async {
        bool? confirmed = await Utility.showConfirmationDialog(
          context,
          'Delete Request',
          'Are you sure you want to delete this notification?',
        );
        if (confirmed == true) {
          await _userService.hideNotification(notification.id);
        }
      },
      icon: Icon(Icons.delete, color: Colors.grey),
    );
  }
}
