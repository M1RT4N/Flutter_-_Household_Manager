import 'package:flutter/material.dart';
import 'package:household_manager/common/page_template.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Profile',
      child: Center(
        child: Text('Prifile Page Content'),
      ),
    );
  }
}
