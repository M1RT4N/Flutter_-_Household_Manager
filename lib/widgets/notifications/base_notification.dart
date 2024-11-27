import 'package:flutter/material.dart';

const _contentActionGap = 30.0;
const _titleFontSize = 18.0;
const _descriptionFontSize = 12.0;
const _titleDescriptionGap = 4.0;
const _iconSize = 40.0;
const _iconRightPadding = 12.0;

abstract class BaseNotification {
  final String title;
  final String description;
  final IconData icon;

  BaseNotification(
      {required this.icon, required this.title, required this.description});

  Widget build(BuildContext context) {
    return Row(
      children: [
        buildIcon(),
        SizedBox(width: _iconRightPadding),
        buildContent(),
        SizedBox(width: _contentActionGap),
        buildAction(context),
      ],
    );
  }

  Widget buildIcon() {
    return Icon(
      icon,
      size: _iconSize,
      color: Colors.grey[500],
    );
  }

  Widget buildContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: _titleFontSize, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: _titleDescriptionGap),
          Text(
            description,
            style:
                TextStyle(fontSize: _descriptionFontSize, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildAction(BuildContext context);
}
