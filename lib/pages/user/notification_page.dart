import 'package:flutter/material.dart';
import 'package:household_manager/common/page_template.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Notifications',
      child: Center(
        child: Text('Notifications Page Content'),
      ),
    );
  }
}
