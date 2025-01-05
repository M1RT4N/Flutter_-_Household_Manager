import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';

const _initialsSize = 12.0;
const _initialsRadius = 16.0;

class UserAvatar extends StatelessWidget {
  final VoidCallback onPressed;
  final userService = GetIt.instance<UserService>();

  UserAvatar({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return LoadingStreamBuilder(
        stream: userService.getUserStream,
        builder: (context, user_) {
          final user = user_ as User;

          return IconButton(
              icon: CircleAvatar(
                radius: _initialsRadius,
                backgroundColor: Colors.blue,
                child: Text(
                  Utility.getUserInitials(user.name),
                  style:
                      TextStyle(color: Colors.white, fontSize: _initialsSize),
                ),
              ),
              onPressed: () => onPressed());
        });
  }
}
