import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';

const _initialsSize = 12.0;
const _imageBorderWidth = 1.0;
const _imageRadiusFactor = 2.0;

class UserAvatar extends StatelessWidget {
  final VoidCallback onPressed;
  final userService = GetIt.instance<UserService>();
  final double initialsRadius;

  UserAvatar({super.key, required this.onPressed, this.initialsRadius = 16.0});

  @override
  Widget build(BuildContext context) {
    return LoadingStreamBuilder(
        stream: userService.getUserStream,
        builder: (context, user_) {
          final user = user_ as User;

          return IconButton(
            icon: _buildAvatar(user),
            onPressed: () => onPressed(),
            iconSize: initialsRadius * _imageRadiusFactor,
            constraints: BoxConstraints(),
            splashRadius: initialsRadius,
            visualDensity: VisualDensity.compact,
          );
        });
  }

  Widget _buildAvatar(User user) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey, width: _imageBorderWidth),
        color: Colors.transparent,
      ),
      child: CircleAvatar(
        radius: initialsRadius - _imageRadiusFactor,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        backgroundColor:
            user.avatarUrl != null ? Colors.transparent : Colors.orange,
        child: user.avatarUrl == null
            ? Text(
                Utility.getUserInitials(user.name),
                style: TextStyle(color: Colors.white, fontSize: _initialsSize),
              )
            : null,
      ),
    );
  }
}
