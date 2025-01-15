import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/filters/stat_range.dart';
import 'package:household_manager/utils/tabs/todo_section.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

const _padding = EdgeInsets.symmetric(vertical: 28, horizontal: 16);
const _verticalGap = SizedBox(height: 28);
const _verticalLegendGap = SizedBox(height: 20);
const _chartTitleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
const _filterPaddingPhone = SizedBox(height: 10);
const _filterPaddingWeb = SizedBox(width: 10);
const _legendLabelsPadding = SizedBox(width: 10);
const _legendDotSize = 14.0;
const _legendTextStyle = TextStyle(fontSize: 10);

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  StatRange _selectedRange = StatRange.Week;
  String? _selectedMemberId = GetIt.instance<UserService>().getUser!.id;
  int? _selectedSectionIndex;
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
        final member = _selectedMemberId == null
            ? householdDto.members
            : householdDto.members
                .where((m) => m.id == _selectedMemberId)
                .toList();
        final sections = _selectedSectionIndex == null
            ? TodoSection.statSections
            : [TodoSection.statSections[_selectedSectionIndex!]];
        return Padding(
          padding: _padding,
          child: Center(
            child: Column(
              children: [
                _buildFilterSection(householdDto.members),
                _verticalGap,
                _verticalLegendGap,
                Text('Household Statistics:', style: _chartTitleStyle),
                _verticalLegendGap,
                _buildLegend(sections),
                _verticalLegendGap,
                _buildBarChart(todos, member, sections),
                _verticalGap,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(List<User> members) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        isWeb
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Filters:', style: _chartTitleStyle),
                  _filterPaddingWeb,
                  _filterPaddingWeb,
                  Expanded(child: _buildRangePicker()),
                  _filterPaddingWeb,
                  Expanded(child: _buildMemberPicker(members)),
                  _filterPaddingWeb,
                  Expanded(child: _buildSectionPicker()),
                ],
              )
            : Column(
                children: [
                  Text('Filters:', style: _chartTitleStyle),
                  _buildRangePicker(),
                  _filterPaddingPhone,
                  _buildMemberPicker(members),
                  _filterPaddingPhone,
                  _buildSectionPicker(),
                ],
              ),
      ],
    );
  }

  Widget _buildLegend(List<TodoSection> sections) {
    return Wrap(
      children: [
        for (final section in sections) ...[
          Container(
            width: _legendDotSize,
            height: _legendDotSize,
            decoration: BoxDecoration(
              color: section.color,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            section.label,
            style: _legendTextStyle,
          ),
          _legendLabelsPadding,
        ]
      ],
    );
  }

  Widget _buildBarChart(
      List<Todo> todos, List<User> members, List<TodoSection> sections) {
    return Expanded(
      child: BarChart(
        swapAnimationDuration: Duration.zero,
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (rodIndex < 0 ||
                    rodIndex >= TodoSection.statSections.length) {
                  return null;
                }
                return BarTooltipItem(
                  '${sections[rodIndex].label}: ${rod.toY.toInt()}',
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
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
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
                reservedSize: 50,
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < members.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  for (final section in sections)
                    BarChartRodData(
                      toY: section
                          .filter(todos, members[i], _selectedRange)
                          .length
                          .toDouble(),
                      color: section.color,
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
        labelText: 'Past:',
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

  Widget _buildMemberPicker(List<User> members) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Member:',
      ),
      value: _selectedMemberId,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('All Members'),
        ),
        for (final member in members)
          DropdownMenuItem<String>(
            value: member.id,
            child: Text(member.name),
          ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedMemberId = value;
        });
      },
    );
  }

  Widget _buildSectionPicker() {
    return DropdownButtonFormField<int?>(
      decoration: InputDecoration(
        labelText: 'Section:',
      ),
      value: _selectedSectionIndex,
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('AllSections'),
        ),
        for (var i = 0; i < TodoSection.statSections.length; i++)
          DropdownMenuItem<int?>(
            value: i,
            child: Text(TodoSection.statSections[i].label),
          ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSectionIndex = value;
        });
      },
    );
  }
}
