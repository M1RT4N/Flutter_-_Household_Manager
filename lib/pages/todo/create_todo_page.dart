import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
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
  final _createdForController =
      TextEditingController(text: GetIt.instance<UserService>().getUser!.id);
  final _descriptionController = TextEditingController();
  final _dateController =
      TextEditingController(text: Utility.formatDate(DateTime.now()));

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate<Household?>(
      title: 'Create TODO',
      stream: GetIt.instance<HouseholdService>().getHouseholdStream,
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
      showBackArrow: true,
      showDrawer: false,
    );
  }

  // TODO: implement or use phone design
  Widget _buildBodyWeb(BuildContext context, Household? household) {
    return Container();
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
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: 'Description:',
                        hintText: 'Write description'),
                    controller: _descriptionController,
                  ),
                  _verticalGap,
                  DropdownButtonFormField<String>(
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
                  ),
                  _verticalGap,
                  TextField(
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: "Deadline:",
                          hintText: 'Choose deadline'),
                      readOnly: true,
                      controller: _dateController,
                      onTap: () => Utility.pickDate(context, _dateController)),
                  _verticalGap,
                  LoadingStadiumButton(buttonText: 'Create', onPressed: _create)
                ],
              ),
            ),
          );
        });
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
