import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/info_bubble.dart';
import 'package:household_manager/widgets/todo_tile.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';

const _calendarDaysLimit = 2048;
const _maxEventLines = 3;
const _eventTopPadding = 32.0;
const _calendarSize = 500.0;
const _calendarControlSize = 125.0;
const _calendarControlPadding = 8.0;
const _calendarNoTodosPadding = 5.0;
const _calendarTodoListPadding = 25.0;
const _calendarDateTextPadding = 15.0;
const _calendarDateTextFontSize = 16.0;
const _calendarBorderWidth = 1.0;
const _calendarBottomContainerPadding = 5.0;
const _calendarHorizontalContainerPadding = 24.0;

class CalendarView extends StatefulWidget {
  final List<Todo> todos;
  final bool showCompleted;
  final bool showOnlyMine;
  final ValueChanged<bool> onShowCompletedChanged;
  final ValueChanged<bool> onShowOnlyMineChanged;

  const CalendarView({
    super.key,
    required this.todos,
    required this.showCompleted,
    required this.showOnlyMine,
    required this.onShowCompletedChanged,
    required this.onShowOnlyMineChanged,
  });

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late CrCalendarController _calendarController;
  final _monthNameNotifier = ValueNotifier<String>('');
  List<Todo> _selectedTodos = [];

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCalendarIfNeeded(oldWidget);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _monthNameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildCalendarContainer(),
      if (_calendarController.selectedDate != null) _buildSelectedDateText(),
      if (_calendarController.selectedDate == null && _selectedTodos.isNotEmpty)
        _buildOldViewText(),
      if (_selectedTodos.isNotEmpty) _buildTodoList(),
      if (_selectedTodos.isEmpty) _buildNoTodosInfo(),
    ]);
  }

  void _initializeCalendar() {
    _calendarController = _createCalendarController(widget.todos);
    _setTexts(DateTime.now().year, DateTime.now().month);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showCurrentMonth();
    });
  }

  void _updateCalendarIfNeeded(CalendarView oldWidget) {
    if (oldWidget.todos != widget.todos ||
        oldWidget.showCompleted != widget.showCompleted ||
        oldWidget.showOnlyMine != widget.showOnlyMine) {
      final newCalendarController = _createCalendarController(widget.todos);
      newCalendarController.date = DateTime.now();
      newCalendarController.selectedDate = null;
      _setTexts(DateTime.now().year, DateTime.now().month);
      _calendarController = newCalendarController;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showCurrentMonth();
      });
    }
  }

  Widget _buildCalendarContainer() {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: _calendarHorizontalContainerPadding),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[850] ?? Colors.grey,
          width: _calendarBorderWidth,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox(
        width: _calendarSize,
        height: _calendarSize + _calendarControlSize,
        child: Column(
          children: [
            _buildCalendarHeader(),
            _buildCalendar(),
            _buildCalendarControl(),
            const SizedBox(height: _calendarBottomContainerPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            _changeCalendarPage(false);
          },
        ),
        ValueListenableBuilder(
          valueListenable: _monthNameNotifier,
          builder: (ctx, value, child) => Text(
            value,
            style: TextStyle(
                fontSize: _calendarDateTextFontSize,
                color: Colors.amber[800],
                fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            _changeCalendarPage(true);
          },
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      width: _calendarSize,
      height: _calendarSize,
      child: CrCalendar(
        firstDayOfWeek: WeekDay.monday,
        eventsTopPadding: _eventTopPadding,
        initialDate: DateTime.now(),
        maxEventLines: _maxEventLines,
        controller: _calendarController,
        forceSixWeek: true,
        onDayClicked: _showDayEvents,
        minDate: DateTime.now().subtract(
          const Duration(days: _calendarDaysLimit),
        ),
        maxDate: DateTime.now().add(
          const Duration(days: _calendarDaysLimit),
        ),
      ),
    );
  }

  Widget _buildSelectedDateText() {
    return Column(
      children: [
        const SizedBox(height: _calendarDateTextPadding),
        Text(
          DateFormat('dd MMMM yyyy').format(_calendarController.selectedDate!),
          style: TextStyle(
              fontSize: _calendarDateTextFontSize,
              color: Colors.amber[800],
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildOldViewText() {
    return Column(
      children: [
        const SizedBox(height: _calendarDateTextPadding),
        Text(
          "(Old View ${_monthNameNotifier.value})",
          style: TextStyle(
              fontSize: _calendarDateTextFontSize,
              color: Colors.amber[850],
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTodoList() {
    return Column(
      children: [
        const SizedBox(height: _calendarTodoListPadding),
        LoadingFutureBuilder(
          future: GetIt.instance<TodoService>().fetchUsers(_selectedTodos),
          builder: (context, todosWithUsers) {
            return Column(
              children: [
                ...todosWithUsers.map(
                  (todo) => TodoTile(
                    todo: todo.todo,
                    creator: todo.creator,
                    assignee: todo.assignee,
                    showTickMark: todo.todo.completedAt == null &&
                        todo.todo.deletedAt == null,
                    onClick: () => Modular.to.pushNamed(
                      AppRoute.editTodo.path,
                      arguments: todo,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoTodosInfo() {
    return Column(
      children: [
        const SizedBox(height: _calendarNoTodosPadding),
        const InfoBubble(labelText: 'No TODOs for selected day.'),
      ],
    );
  }

  Widget _buildCalendarControl() {
    return Column(
      children: [
        Center(
          child: ElevatedButton.icon(
            onPressed: _showCurrentMonth,
            icon: Icon(Icons.today),
            label: Text('Current Month'),
          ),
        ),
        const SizedBox(height: _calendarControlPadding),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: widget.showCompleted,
                onChanged: (bool? value) {
                  widget.onShowCompletedChanged(value ?? false);
                },
              ),
              const Text('Show completed'),
              Checkbox(
                value: widget.showOnlyMine,
                onChanged: (bool? value) {
                  widget.onShowOnlyMineChanged(value ?? true);
                },
              ),
              const Text('Show only mine'),
            ],
          ),
        ),
      ],
    );
  }

  void _changeCalendarPage(bool showNext) => showNext
      ? _calendarController.swipeToNextMonth()
      : _calendarController.swipeToPreviousPage();

  void _showCurrentMonth() {
    _calendarController.goToDate(DateTime.now());
    _calendarController.selectedDate = null;
  }

  CrCalendarController _createCalendarController(List<Todo> todos) {
    final events = todos
        .map((todo) => CalendarEventModel(
              name: todo.title,
              begin: todo.createdAt.toDate(),
              end: todo.deadline.toDate(),
              eventColor: Utility.pickRandomColor(todo.id),
            ))
        .toList();

    return CrCalendarController(
        onSwipe: _onCalendarPageChanged, events: events);
  }

  void _onCalendarPageChanged(int year, int month) {
    _setTexts(year, month);
  }

  void _setTexts(int year, int month) {
    final updatedDate = DateTime(year, month);
    final formattedDate = DateFormat('yyyy MMMM').format(updatedDate);
    _monthNameNotifier.value = formattedDate;
  }

  void _showDayEvents(List<CalendarEventModel> events, DateTime day) {
    var selectedTodos = widget.todos.where((todo) {
      return events.any((event) => event.name.contains(todo.title));
    }).toList();

    setState(() {
      _selectedTodos = selectedTodos;
    });
  }
}
