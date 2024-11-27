import 'package:flutter/material.dart';
import 'package:household_manager/widgets/common/page_template.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Household Members',
      child: Center(
        child: Text('Members Page Content'),
      ),
    );
  }
}
