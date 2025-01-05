import 'package:flutter/material.dart';
import 'package:household_manager/pages/common/page_template.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Statistics',
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: Text('Statistics'),
    );
  }
}
