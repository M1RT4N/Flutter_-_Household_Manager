import 'package:flutter/material.dart';

enum NotificationType {
  userJoined(Icons.person_add),
  userRejected(Icons.person_remove),
  userLeft(Icons.exit_to_app),
  todoAssigned(Icons.assignment),
  todoCompleted(Icons.check_circle);

  final IconData icon;

  const NotificationType(this.icon);

  IconData getIcon() {
    return icon;
  }
}
