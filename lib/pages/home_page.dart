import 'package:flutter/material.dart';
import 'package:household_manager/mocks/home_page_mock.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/models/todo_data.dart';

const _AVATAR_SIZE = 50.0;
const _SECTION_BUTTON_PADDING = 5.0;

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
            Container(
              color: Colors.black,
              padding:
                  EdgeInsets.symmetric(horizontal: _SECTION_BUTTON_PADDING),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionButton("TODO's", () {}),
                      SizedBox(
                        width: _SECTION_BUTTON_PADDING,
                      ),
                      _buildSectionButton("HouseHold", () {}),
                    ],
                  ),
                ],
              ),
            ),
            _buildMainSection()
          ],
        ));
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {},
        icon: _buildProfileIcon(),
      ),
      title: Text('Home'),
      actions: <Widget>[
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
      ],
      centerTitle: true,
    );
  }

  Widget _buildSectionButton(String buttonText, VoidCallback onPressed) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Colors.red))),
            backgroundColor: WidgetStatePropertyAll(Colors.red)),
      ),
    );
  }

  Widget _buildProfileIcon() {
    return IconButton(
      onPressed: () {},
      icon: Container(
        width: _AVATAR_SIZE,
        height: _AVATAR_SIZE,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
        child: Center(
          child: Text(
            '${_getInitialFromString(widget.profileInfo.firstName)}${_getInitialFromString(widget.profileInfo.lastName)}',
            style: TextStyle(color: Colors.white),
          ),
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
            return Center(child: CircularProgressIndicator());
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
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Text(todo.deadline.toString()), Text(todo.taskDescription)],
      ),
    );
  }
}
