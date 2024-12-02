import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';

class CreateTodoPage extends StatefulWidget {
  const CreateTodoPage({super.key});

  @override
  State<CreateTodoPage> createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  final _todoService = GetIt.instance<TodoService>();
  final _createdForController =
      TextEditingController(text: GetIt.instance<UserService>().getUser!.id);
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Create TODO',
      bodyFunction: _buildBody,
      showBackArrow: true,
      showDrawer: false,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Todo for:',
                hintText: 'Choose member',
              ),
              value: _createdForController.text,
              items: appState.household!.members
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (m) => _createdForController.text = m!,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: 'Description:', hintText: 'Write description'),
              controller: _descriptionController,
            ),
            TextField(
                decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: "Deadline:",
                    hintText: 'Choose deadline'),
                readOnly: true,
                controller: _dateController,
                onTap: _pickDate),
            LoadingStadiumButton(buttonText: 'Create', onPressed: _create)
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.fromMicrosecondsSinceEpoch(8640000000000000));

    if (pickedDate != null) {
      _dateController.text = Utility.formatDate(pickedDate);
    } else {
      _dateController.clear();
    }
  }

  void _create() async {
    String? errorMessage = _validateInputs();
    if (errorMessage != null) {
      return showTopSnackBar(context, errorMessage, Colors.red);
    }

    await _todoService.create(
      _createdForController.text,
      Timestamp.fromDate(Utility.parseDate(_dateController.text)),
      _descriptionController.text,
    );

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
