import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/notifications/notification_type.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/user_avatar.dart';

const _sectionPaddingHor = 16.0;
const _titleFontSize = 18.0;
const _titleDescriptionGap = 4.0;
const _cardBottomPadding = 12.0;
const _borderRadius = 8.0;
const _boxPadding = 16.0;
const _maxWidthFactor = 0.5;
const _minWidthFactor = 1.0;
const _mediaControlMinSize = 600.0;
const _titleLinkIconLeftPadding = 4.0;
const _statusUpperPadding = 8.0;
const _dateIconSize = 14.0;
const _dateIconPadding = 3.0;
const _userSpacing = 16.0;
const _smallUserAvatarRadius = 10.0;
const _smallUserAvatarFontSize = 8.0;
const _statusIconSize = 16.0;
const _statusDatePadding = 3.0;
const _statusDateFontSize = 16.0;

class TodoTile extends StatelessWidget {
  final Todo todo;
  final User creator;
  final User assignee;
  final VoidCallback onClick;
  final bool showTickMark;

  final _userService = GetIt.instance<UserService>();

  TodoTile(
      {super.key,
      required this.todo,
      required this.creator,
      required this.assignee,
      required this.onClick,
      this.showTickMark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: _cardBottomPadding),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: MediaQuery.of(context).size.width > _mediaControlMinSize
              ? _maxWidthFactor
              : _minWidthFactor,
          child: _buildCard(context),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
        side: BorderSide(color: Colors.grey[600]!),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: _boxPadding,
          horizontal: _boxPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: EdgeInsets.symmetric(
                  horizontal: _sectionPaddingHor,
                ).vertical),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleRow(),
                    SizedBox(height: _titleDescriptionGap),
                    _buildDetailsColumn(),
                  ],
                ),
              ),
            ),
            if (showTickMark)
              IconButton(
                onPressed: () => _completeTodo(context, todo),
                icon: Icon(Icons.check),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: onClick,
      child: Wrap(
        children: [
          Text(
            todo.title,
            style: TextStyle(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: EdgeInsets.only(left: _titleLinkIconLeftPadding),
            child: Icon(
              Icons.link,
              size: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateRow(),
        Text(
          todo.description,
          style: TextStyle(color: Colors.grey[400]),
        ),
        SizedBox(height: _statusUpperPadding),
        _buildUserRows(),
        if (todo.completedAt != null)
          _buildStatusRow(
            icon: Icons.check,
            color: Colors.green,
            label: "COMPLETED",
            date: todo.completedAt!,
          ),
        if (todo.deletedAt != null)
          _buildStatusRow(
            icon: Icons.delete_forever_outlined,
            color: Colors.red,
            label: "DELETED",
            date: todo.deletedAt!,
          ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Icon(
          Icons.calendar_month,
          size: _dateIconSize,
          color: Colors.grey[600],
        ),
        SizedBox(width: _dateIconPadding),
        Text(
          Utility.formatDate(todo.createdAt.toDate()),
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          ' - ',
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          Utility.formatDate(todo.deadline.toDate()),
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildUserRows() {
    return Wrap(
      spacing: _userSpacing,
      children: [
        _buildUserRow('Creator: ', creator),
        _buildUserRow('Assignee: ', assignee),
      ],
    );
  }

  Widget _buildUserRow(String label, User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey)),
        UserAvatar(
          selectedUser: user,
          initialsRadius: _smallUserAvatarRadius,
          initialsFontSize: _smallUserAvatarFontSize,
        ),
        Text(
          ' ${user.name}',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color color,
    required String label,
    required Timestamp date,
  }) {
    return Row(
      children: [
        Icon(icon, size: _statusIconSize, color: color),
        SizedBox(width: _statusDatePadding),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: _dateIconPadding),
        Text(
          '(${Utility.formatDate(date.toDate())})',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: _statusDateFontSize,
          ),
        ),
      ],
    );
  }

  void _completeTodo(BuildContext context, Todo todo) async {
    final updatedTodo =
        todo.copyWith(completedAt: Timestamp.fromDate(DateTime.now()));
    await Utility.performActionAndShowInfo(
        context: context,
        action: () async {
          // Send notification to creator but only if creator is not assignee
          if (todo.createdById != todo.createdForId) {
            await _userService.addNotification(
              todo.createdById,
              NotificationType.todoCompleted,
              'TODO You Assigned Completed',
              'Yor TODO ${todo.title} was marked as completed.',
              todo.id,
            );
          }

          // Send notification to assignee
          await _userService.addNotification(
            todo.createdById,
            NotificationType.todoCompleted,
            'You Successfully Completed TODO',
            'Congratulations! You have successfully completed the TODO ${todo.title}.',
            todo.id,
          );

          await GetIt.instance<TodoService>().updateTodo(updatedTodo);
          return null;
        },
        successMessage: 'TODO completed.');
  }
}
