import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/todo.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/static_page_template.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';

const _padding = EdgeInsets.all(20);
const _cardElevation = 4.0;
const _borderRadius = 12.0;
const _labelTextStyle = TextStyle(fontSize: 18, color: Colors.grey);
const _editableTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
const _labelTextGap = SizedBox(width: 8);
const _rowGap = SizedBox(height: 8);
const _cardMargin = EdgeInsets.all(16);

class EditTodoPage extends StatefulWidget {
  const EditTodoPage({super.key});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late Todo todo;
  late User creator;
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _editableTextFocusNode = FocusNode();
  final userId = GetIt.instance<UserService>().getUser!.id;
  final todoService = GetIt.instance<TodoService>();

  @override
  void initState() {
    todo = Modular.args.data[0] as Todo;
    creator = Modular.args.data[1] as User;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StaticPageTemplate(
        title: 'Todos',
        bodyFunction: _buildBody,
        showNotifications: false,
        showBackArrow: true,
        showDrawer: false);
  }

  Widget _buildBody(BuildContext context) {
    _descriptionController.text = todo.description;
    _dateController.text = Utility.formatDate(todo.deadline.toDate());

    return Card(
        margin: _cardMargin,
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius)),
        child: Padding(
          padding: _padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description:', style: _labelTextStyle),
              _rowGap,
              _buildDescriptionRow(),
              _rowGap,
              _buildDeadlineRow(),
              _rowGap,
              _buildCreatorRow(),
              _rowGap,
              _buildButtonsRow()
            ],
          ),
        ));
  }

  Widget _buildDescriptionRow() {
    return Row(
      children: [
        Expanded(
          child: userId == creator.id
              ? EditableText(
                  maxLines: null,
                  controller: _descriptionController,
                  focusNode: _editableTextFocusNode,
                  style: _editableTextStyle,
                  cursorColor: Colors.grey,
                  backgroundCursorColor: Colors.amber,
                )
              : Text(
                  todo.description,
                  style: _editableTextStyle,
                ),
        ),
        if (userId == creator.id)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editableTextFocusNode.requestFocus(),
          ),
      ],
    );
  }

  Widget _buildDeadlineRow() {
    return Row(children: [
      Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 135),
          child: TextField(
            decoration: const InputDecoration(
              icon: Icon(Icons.calendar_today),
              labelText: "Deadline:",
              hintText: 'Choose deadline',
            ),
            readOnly: true,
            controller: _dateController,
            onTap: () {},
          ),
        ),
      ),
      if (userId == creator.id)
        IconButton(
          onPressed: () => Utility.pickDate(context, _dateController),
          icon: Icon(Icons.edit),
        )
    ]);
  }

  Widget _buildCreatorRow() {
    return Row(
      children: [
        Text(
          'CreatedBy:',
          style: _labelTextStyle,
        ),
        _labelTextGap,
        Text(
          userId == creator.id ? 'You' : creator.name,
          style: _editableTextStyle,
        )
      ],
    );
  }

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LoadingStadiumButton(buttonText: 'Delete', onPressed: _deleteTodo),
        LoadingStadiumButton(
            buttonText: 'Save',
            onPressed: () => _updateTodo(
                  _descriptionController.text,
                  _dateController.text,
                ))
      ],
    );
  }

  void _updateTodo(String newDescription, String newDeadline) async {
    final updatedTodo = todo.copyWith(
        description: newDescription,
        deadline: Timestamp.fromDate(Utility.parseDate(newDeadline)));
    await Utility.performActionAndShowInfo(
        context, () => todoService.updateTodo(updatedTodo), 'Todo updated.');
  }

  void _deleteTodo() async {
    final updatedTodo =
        todo.copyWith(deletedAt: Timestamp.fromDate(DateTime.now()));
    final res =
        await Utility.showConfirmationDialog(context, 'Delete', 'Delete todo?');
    if (res == true) {
      await Utility.performActionAndShowInfo(
          context, () => todoService.updateTodo(updatedTodo), 'Todo deleted.');
    }
    Modular.to.pop();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    _editableTextFocusNode.dispose();
    super.dispose();
  }
}
