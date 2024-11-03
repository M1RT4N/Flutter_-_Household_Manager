import 'package:flutter/material.dart';
import 'package:household_manager/mocks/home_page_mock.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/models/todo_data.dart';
import 'package:household_manager/pages/house_hold_page.dart';
import 'package:household_manager/pages/manage_todos_page.dart';
import 'package:household_manager/pages/notifications_page.dart';
import 'package:household_manager/pages/profile_page.dart';
import 'package:intl/intl.dart';

const _AVATAR_SIZE = 30.0;
const _CLOSEST_TO_DEADLINE_FONT_SIZE = 20.0;
const _TODO_PADDING = 10.0;
const _DEADLINE_FONT_SIZE = 20.0;
const _SPACE_BEFORE_DESCRIPTION = 20.0;

class HomePage extends StatefulWidget {
  final ProfileInfo profileInfo;

  const HomePage({super.key, required this.profileInfo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildMainSection(),
          ],
        ));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: _buildIconButton(_buildProfileIcon(), ProfilePage()),
      title: Text(
        'Closest to deadline:',
        style: TextStyle(
            fontSize: _CLOSEST_TO_DEADLINE_FONT_SIZE,
            fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        _buildIconButton(Icon(Icons.list_alt), ManageTodosPage()),
        _buildIconButton(Icon(Icons.home), HouseHoldPage()),
        _buildIconButton(Icon(Icons.notifications), NotificationsPage()),
      ],
      // centerTitle: true,
    );
  }

  Widget _buildIconButton(Widget icon, Widget nextPage) {
    return IconButton(
      icon: icon,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => nextPage),
        );
      },
    );
  }

  Widget _buildProfileIcon() {
    return Container(
      width: _AVATAR_SIZE,
      height: _AVATAR_SIZE,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
      child: Center(
        child: Text(
          '${_getInitialFromString(widget.profileInfo.firstName)}${_getInitialFromString(widget.profileInfo.lastName)}',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  String _getInitialFromString(String input) => input.isEmpty ? '' : input[0];

  Widget _buildMainSection() {
    return FutureBuilder(
        future: HomePageMock().getLatestFiveBeforeDeadline(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not fetch data'));
          }

          if (!snapshot.hasData) {
            return Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          List<TodoData> top5BeforeDeadline = snapshot.data!;

          return Column(
            children: [
              for (var i = 0; i < top5BeforeDeadline.length; i++)
                _buildTodoRow(top5BeforeDeadline[i])
            ],
          );
        });
  }

  Widget _buildTodoRow(TodoData todo) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 2)),
        color: Colors.blue,
      ),
      padding: EdgeInsets.all(_TODO_PADDING),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Deadline: ${DateFormat("dd.M. yyyy HH:MM").format(todo.deadline)}",
            style: TextStyle(fontSize: _DEADLINE_FONT_SIZE),
          ),
          Text(
            "Created by: ${todo.assigner.firstName} ${todo.assigner.lastName}",
          ),
          SizedBox(height: _SPACE_BEFORE_DESCRIPTION),
          Text(todo.taskDescription)
        ],
      ),
    );
  }
}
