import 'package:flutter/material.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/utils/utility.dart';

const _maxWidth = 1000.0;
const double _sectionPaddingHor = 16.0;
const double _sectionMarginVer = 4.0;
const double _sectionMarginHor = 16.0;
const double _sectionBubbleRadius = 8.0;
const _descriptionTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.white,
);
const _contentPadding = EdgeInsets.symmetric(
  horizontal: _sectionPaddingHor,
);
const _subtitleStyle = TextStyle(color: Colors.white70);
const _bubbleMargin = EdgeInsets.symmetric(
  horizontal: _sectionMarginHor,
  vertical: _sectionMarginVer,
);

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: _maxWidth),
      margin: _bubbleMargin,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        color: Colors.blue,
        borderRadius: BorderRadius.circular(_sectionBubbleRadius),
      ),
      child: ListTile(
        contentPadding: _contentPadding,
        title: Wrap(
          children: [
            Text('Description: '),
            Text(
              todo.description,
              style: _descriptionTextStyle,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created by: ${todo.id}',
              style: _subtitleStyle,
            ),
            Text('Deadline: ${Utility.formatDate(todo.deadline.toDate())}',
                style: _subtitleStyle),
          ],
        ),
      ),
    );
  }
}
