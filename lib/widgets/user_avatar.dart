import 'package:flutter/material.dart';
import 'package:household_manager/utils/utility.dart';

const _initialsSize = 12.0;
const _initialsRadius = 16.0;

class UserAvatar extends StatelessWidget {
  final String? name;
  final VoidCallback onPressed;

  const UserAvatar({super.key, required this.name, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: CircleAvatar(
          radius: _initialsRadius,
          backgroundColor: Colors.blue,
          child: Text(
            Utility.getUserInitials(name),
            style: TextStyle(color: Colors.white, fontSize: _initialsSize),
          ),
        ),
        onPressed: () => onPressed());
  }
}
