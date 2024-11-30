import 'package:flutter/material.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/test_page_template.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TestPageTemplate(
      title: 'Statistics',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    return Center(
      child: Text('Statistics'),
    );
  }
}
