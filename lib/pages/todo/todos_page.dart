import 'package:flutter/material.dart';
import 'package:household_manager/widgets/common/page_template.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'TODOs',
      child: Center(
        child: Text('TODO Page Content'),
      ),
    );
  }
}
