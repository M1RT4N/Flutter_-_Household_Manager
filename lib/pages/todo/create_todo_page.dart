import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/notifications/notification_type.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _padding = EdgeInsets.all(20);
const _verticalGap = SizedBox(height: 8);

class CreateTodoPage extends StatefulWidget {
  const CreateTodoPage({super.key});

  @override
  State<CreateTodoPage> createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  final _todoService = GetIt.instance<TodoService>();
  final _userService = GetIt.instance<UserService>();
  final _householdService = GetIt.instance<HouseholdService>();

  final _createdForController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController =
      TextEditingController(text: Utility.formatDate(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    _createdForController.text = _userService.getUser!.id;

    return LoadingPageTemplate<Household?>(
      title: 'Create TODO',
      stream: _householdService.getHouseholdStream,
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
      showBackArrow: true,
      showDrawer: false,
    );
  }

  // TODO: implement or use phone design
  Widget _buildBodyWeb(BuildContext context, Household? household) {
    return _buildBodyPhone(context, household);
  }

  Widget _buildBodyPhone(BuildContext context, Household? household) {
    if (household == null) {
      return Center(child: Text('No data available.'));
    }

    return LoadingFutureBuilder(
        future: GetIt.instance<UserService>().getUsersByIds(household.members),
        builder: (context, members) {
          return Center(
            child: Container(
              padding: _padding,
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDescriptionField(),
                  _verticalGap,
                  _buildDropdownButton(members),
                  _verticalGap,
                  _buildDeadlinePicker(),
                  _verticalGap,
                  LoadingStadiumButton(
                    idleStateWidget: Text('Create'),
                    onPressed: _create,
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _buildDescriptionField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
          labelText: 'Description:', hintText: 'Write description'),
      controller: _descriptionController,
    );
  }

  Widget _buildDropdownButton(List<User> members) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Todo for:',
        hintText: 'Choose member',
      ),
      value: _createdForController.text,
      items: members
          .map((m) => DropdownMenuItem(
                value: m.id,
                child: Text(m.name),
              ))
          .toList(),
      onChanged: (m) => _createdForController.text = m!,
    );
  }

  Widget _buildDeadlinePicker() {
    return TextField(
      decoration: const InputDecoration(
          icon: Icon(Icons.calendar_today),
          labelText: "Deadline:",
          hintText: 'Choose deadline'),
      readOnly: true,
      controller: _dateController,
      onTap: () => Utility.pickDate(context, _dateController),
    );
  }

  void _create() async {
    String? errorMessage = _validateInputs();
    if (errorMessage != null) {
      return showTopSnackBar(context, errorMessage, Colors.red);
    }

    final todo = await _todoService.create(
      _createdForController.text,
      Utility.parseDate(_dateController.text),
      _descriptionController.text,
    );

    if (_userService.getUser!.id != todo.createdForId) {
      await _userService.addNotification(
        todo.createdForId,
        NotificationType.todoAssigned,
        'New TODO assigned.',
        todo.description,
        null,
      );
    }

    if (mounted) {
      showTopSnackBar(context, 'TODO created.', Colors.green);
      Modular.to.pop();
    }
  }

  String? _validateInputs() {
    if (_createdForController.text.isEmpty) {
      return 'Please, choose member';
    }

    if (_descriptionController.text.isEmpty) {
      return 'Please, provide description';
    }

    if (_dateController.text.isEmpty) {
      return 'Please, choose deadline';
    }

    return null;
  }

  @override
  void dispose() {
    _createdForController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
