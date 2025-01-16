import 'package:flutter/material.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/widgets/user_avatar.dart';

const _labelTextStyle = TextStyle(fontSize: 18, color: Colors.grey);
const _smallUserAvatarRadius = 10.0;
const _smallUserAvatarFontSize = 8.0;
const _labelTextGap = SizedBox(width: 8);
const _editableTextStyle = TextStyle(fontSize: 16);

class UserWithSmallAvatar extends StatelessWidget {
  final User user;
  final String? label;

  const UserWithSmallAvatar({super.key, required this.user, this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (label != null)
          Text(
            label!,
            style: _labelTextStyle,
          ),
        _labelTextGap,
        UserAvatar(
          selectedUser: user,
          initialsRadius: _smallUserAvatarRadius,
          initialsFontSize: _smallUserAvatarFontSize,
        ),
        _labelTextGap,
        Text(
          user.name,
          style: _editableTextStyle,
        )
      ],
    );
  }
}
