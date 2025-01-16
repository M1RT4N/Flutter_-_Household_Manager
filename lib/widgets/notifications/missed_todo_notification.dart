import 'package:flutter/widgets.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/utils/notifications/notification_type.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/notifications/user_notification.dart';
import 'package:household_manager/models/user.dart' as models;

class MissedTodoNotification extends UserNotification {
  final Todo todo;

  MissedTodoNotification({required this.todo})
      : super(
          notification: models.Notification(
            id: Utility.generateRandomCode(16),
            type: NotificationType.todoOverdue,
            title: 'TODO ${todo.title} is overdue!',
            description:
                'You missed the deadline or are at the exact day for the tasks deadline ${Utility.formatDate(todo.deadline.toDate())}.',
            link: todo.id,
            isHidden: false,
          ),
        );

  @override
  Widget buildAction(BuildContext context) {
    return Container();
  }
}
