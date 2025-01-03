import 'package:flutter/material.dart';
import 'package:household_manager/utils/utility.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double iconRadius;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.name,
    required this.iconRadius,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: iconRadius,
      backgroundColor: Colors.blue,
      child: Text(
        Utility.getUserInitials(name),
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}
