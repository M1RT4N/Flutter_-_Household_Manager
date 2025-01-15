import 'package:flutter/material.dart';

const _noNotificationsFontSize = 16.0;
const _noNotificationsPaddingTop = 25.0;
const _borderRadius = 8.0;
const _boxPadding = 16.0;

class InfoBubble extends StatelessWidget {
  final String labelText;

  const InfoBubble({
    super.key,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: _noNotificationsPaddingTop),
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              side: BorderSide(color: Colors.grey[600]!),
            ),
            child: Padding(
              padding: EdgeInsets.all(_boxPadding),
              child: Text(
                labelText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: _noNotificationsFontSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
