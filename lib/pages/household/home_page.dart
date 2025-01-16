import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/pages/common/static_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/tabs/home_section.dart';
import 'package:household_manager/widgets/calendar_view.dart';
import 'package:household_manager/widgets/info_bubble.dart';
import 'package:household_manager/widgets/navigation_header.dart';
import 'package:household_manager/widgets/todo_tile.dart';

const _topNBeforeDeadline = 10;
const _searchBarPadding = 8.0;
const _searchBarPaddingTop = 16.0;
const _searchBarPaddingBottom = 16.0;
const _mediaControlMinSize = 600.0;
const _checkboxTopPadding = 6.0;
const _searchBarSizeFactorMobile = 0.8;
const _searchBarSizeFactorWeb = 0.4;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final todoService = GetIt.instance<TodoService>();
  final userService = GetIt.instance<UserService>();

  bool _showCompleted = false;
  bool _showOnlyMine = true;
  bool _showOnlyMineSecond = true;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return StaticPageTemplate(
      title: 'Home',
      bodyFunction: (context) {
        return NavigationHeader<HomeSection>(
          values: HomeSection.values,
          selectionCallback: renderSelectedContent,
        );
      },
      showDrawer: true,
      showNotifications: true,
    );
  }

  List<Todo> _filterTodos(List<Todo> todos) {
    if (_showOnlyMine) {
      todos = todos
          .where((todo) => todo.createdForId == userService.getUser!.id)
          .toList();
    }
    if (!_showCompleted) {
      todos = todos.where((todo) => todo.completedAt == null).toList();
    }
    return todos;
  }

  Widget renderSelectedContent(HomeSection section) {
    if (section == HomeSection.CalendarView) {
      return _buildCalendarViewWithContent();
    }

    return LoadingStreamBuilder(
      stream: todoService.getTodoStreamTopNBeforeDeadline(),
      builder: (context, topTodos) {
        return LoadingFutureBuilder(
          future: todoService.fetchUsers(topTodos),
          builder: (context, topNWithUsers) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (topTodos.isNotEmpty)
                    _buildTopTodoCards(context, topNWithUsers)
                  else ...[
                    _buildSearchAndFilterRow(context),
                    InfoBubble(labelText: "No TODOs to show."),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarViewWithContent() {
    return LoadingStreamBuilder(
      stream: GetIt.instance<HouseholdService>().getHouseholdStream,
      builder: (context, household) {
        return LoadingStreamBuilder(
          stream: todoService.getTodoStreamAll(household?.members ?? []),
          builder: (context, todos) {
            return Column(
              children: [
                CalendarView(
                  todos: _filterTodos(todos),
                  showCompleted: _showCompleted,
                  showOnlyMine: _showOnlyMine,
                  onShowCompletedChanged: (value) {
                    setState(() {
                      _showCompleted = value;
                    });
                  },
                  onShowOnlyMineChanged: (value) {
                    setState(() {
                      _showOnlyMine = value;
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTopTodoCards(
      BuildContext context, List<TodoDto> todosWithUsers) {
    todosWithUsers = _filterTopTodos(todosWithUsers, userService.getUser!.id);

    return Column(
      children: [
        _buildSearchAndFilterRow(context),
        SizedBox(height: _searchBarPaddingBottom),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: todosWithUsers.length,
          itemBuilder: (context, index) {
            final todoWithUsers = todosWithUsers[index];
            return TodoTile(
              todo: todoWithUsers.todo,
              creator: todoWithUsers.creator,
              assignee: todoWithUsers.assignee,
              showTickMark: true,
              onClick: () => Modular.to.pushNamed(
                AppRoute.editTodo.path,
                arguments: todoWithUsers,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: _searchBarPaddingTop,
        left: _searchBarPadding,
        right: _searchBarPadding,
        bottom: _searchBarPadding,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < _mediaControlMinSize;
          return Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen
                      ? MediaQuery.of(context).size.width *
                          _searchBarSizeFactorMobile
                      : MediaQuery.of(context).size.width *
                          _searchBarSizeFactorWeb,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(height: _checkboxTopPadding),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _showOnlyMineSecond,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyMineSecond = value!;
                      });
                    },
                  ),
                  Text('Show only mine'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<TodoDto> _filterTopTodos(List<TodoDto> todosWithUsers, String userId) {
    return todosWithUsers
        .where((todoWithUser) {
          final matchesSearch =
              todoWithUser.todo.title.contains(_searchQuery) ||
                  todoWithUser.todo.description.contains(_searchQuery) ||
                  todoWithUser.assignee.name.contains(_searchQuery) ||
                  todoWithUser.creator.name.contains(_searchQuery);
          final matchesHidden =
              !_showOnlyMineSecond || todoWithUser.todo.createdForId == userId;
          return matchesSearch && matchesHidden;
        })
        .take(_topNBeforeDeadline)
        .toList();
  }
}
