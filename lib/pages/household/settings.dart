import 'package:flutter/material.dart';
import 'package:household_manager/common/page_template.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Settings',
      child: Center(
        child: Text('Settings Page Content'),
      ),
    );
  }
}
