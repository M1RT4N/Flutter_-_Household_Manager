import 'package:flutter/material.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/test_page_template.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TestPageTemplate(
      title: 'Home',
      bodyFunction: buildBody,
    );
  }

  Widget buildBody(BuildContext context, AppState appState) {
    return Scaffold(
      body: Column(
        children: [
          Text('User: ${appState.user?.username}'),
          Text('Household name: ${appState.household?.name}'),
          Text('Household code: ${appState.household?.code}'),
        ],
      ),
    );
  }
}
