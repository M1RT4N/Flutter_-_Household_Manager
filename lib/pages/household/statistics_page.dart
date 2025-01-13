import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/enums/stat_range.dart';
import 'package:household_manager/enums/todo_section.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

const _padding = EdgeInsets.symmetric(vertical: 40, horizontal: 16);
const _verticalGap = SizedBox(height: 40);
const _chartNameStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatRange _selectedRange = StatRange.Week;
  final todoService = GetIt.instance<TodoService>();
  final householdService = GetIt.instance<HouseholdService>();

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate<(List<Todo>, Household)>(
      title: 'Statistics',
      stream: Rx.combineLatest2(
          todoService.getTodoStream,
          householdService.getHouseholdStream,
          (todos, household) => (todos, household!)),
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
    );
  }

  // TODO: implement or use phone design
  Widget _buildBodyWeb(BuildContext context, (List<Todo>, Household) res) {
    return _buildBodyPhone(context, res);
  }

  Widget _buildBodyPhone(BuildContext context, (List<Todo>, Household) res) {
    final (todos, household) = res;

    return LoadingFutureBuilder(
      future: householdService.fetchUsers(household),
      builder: (context, householdDto) {
        return Padding(
          padding: _padding,
          child: Center(
            child: Column(
              children: [
                _buildRangePicker(),
                _verticalGap,
                _buildBarChart(todos, householdDto.members),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<Todo> todos, List<User> members) {
    return Expanded(
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${TodoSection.statSections[rodIndex].label}: ${rod.toY.toInt()}',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              axisNameWidget: Text(
                'Household Statistics',
                style: _chartNameStyle,
              ),
              axisNameSize: 40,
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: AxisSide.bottom,
                    child: Column(
                      children: [
                        for (final namePart
                            in members[value.toInt()].name.split(' '))
                          Text(namePart),
                      ],
                    ),
                  );
                },
                reservedSize: 200,
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < members.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  for (final section in TodoSection.statSections)
                    BarChartRodData(
                      toY: section
                          .filter(todos, members[i], _selectedRange)
                          .length
                          .toDouble(),
                      color: section.color,
                      borderRadius: BorderRadius.circular(4),
                    )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangePicker() {
    return DropdownButtonFormField<StatRange>(
      decoration: InputDecoration(
        labelText: 'Range:',
      ),
      value: _selectedRange,
      items: [
        for (final range in StatRange.values)
          DropdownMenuItem<StatRange>(
            value: range,
            child: Text(Utility.getStringFromEnum(range)),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedRange = value;
          });
        }
      },
    );
  }
}
