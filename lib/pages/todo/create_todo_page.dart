import 'package:flutter/material.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/test_page_template.dart';

class CreateTodoPage extends StatelessWidget {
  const CreateTodoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return TestPageTemplate(
      title: 'Create TODO',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    return Center(
      child: Text('Create TODO'),
    );
  }
}
