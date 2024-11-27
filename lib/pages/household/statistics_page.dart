import 'package:flutter/material.dart';
import 'package:household_manager/widgets/common/page_template.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Statistics',
      child: Center(
        child: Text('Statistics Page Content'),
      ),
    );
  }
}
