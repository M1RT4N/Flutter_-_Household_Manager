import 'package:flutter/material.dart';
import 'package:household_manager/widgets/common/page_template.dart';

class CreateTodoPage extends StatelessWidget {
  const CreateTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Create TODO',
      child: Center(
        child: Text('Create TODO Page Content'),
      ),
    );
  }
}
