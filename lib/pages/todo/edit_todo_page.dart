import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/household_dto.dart';
import 'package:household_manager/models/todo_dto.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/pages/common/loading_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/todo_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/notifications/notification_type.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _padding = EdgeInsets.all(20);
const _cardElevation = 4.0;
const _borderRadius = 12.0;
const _labelTextStyle = TextStyle(fontSize: 18, color: Colors.grey);
const _editableTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
const _labelTextGap = SizedBox(width: 8);
const _rowGap = SizedBox(height: 16);
const _cardMargin = EdgeInsets.all(16);

class EditTodoPage extends StatefulWidget {
  const EditTodoPage({super.key});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _editableTextFocusNode = FocusNode();
  final _editableTextFocusNodeTitle = FocusNode();
  final userService = GetIt.instance<UserService>();
  final todoService = GetIt.instance<TodoService>();
  final householdService = GetIt.instance<HouseholdService>();

  late TodoDto? editTodo;
  late bool editable;

  String? _selectedMemberId;

  @override
  void initState() {
    editTodo = Modular.args.data;
    if (editTodo != null) {
      _titleController.text = editTodo!.todo.title;
      _descriptionController.text = editTodo!.todo.description;
      _dateController.text =
          Utility.formatDate(editTodo!.todo.deadline.toDate());
      _selectedMemberId = editTodo!.assignee.id;
      editable = editTodo!.creator.id == userService.getUser!.id &&
          editTodo!.todo.completedAt == null &&
          editTodo!.todo.deletedAt == null;
    } else {
      editable = true;
      _titleController.text = '';
      _dateController.text = Utility.formatDate(DateTime.now());
      _selectedMemberId = userService.getUser!.id;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingPageTemplate(
      stream: householdService.getHouseholdStream,
      title: 'My Todos',
      showNotifications: false,
      showBackArrow: true,
      showDrawer: false,
      bodyFunctionPhone: _buildBodyPhone,
      bodyFunctionWeb: _buildBodyWeb,
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

    return LoadingFutureBuilder<HouseholdDto>(
      future: householdService.fetchUsers(household),
      builder: (context, householdWithUsers) => Center(
        child: Card(
            margin: _cardMargin,
            elevation: _cardElevation,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_borderRadius)),
            child: Padding(
              padding: _padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDescriptionRow(),
                  _rowGap,
                  _buildTitleRow(),
                  _rowGap,
                  _buildDeadlineRow(),
                  _rowGap,
                  _buildAssigneeRow(householdWithUsers.members),
                  _rowGap,
                  if (editTodo == null)
                    _buildCreateButton(household)
                  else
                    _buildCreatorRow(),
                  if (editable && editTodo != null) ...[
                    _rowGap,
                    _buildButtonsRow()
                  ]
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildCreateButton(Household household) {
    return Center(
      child: LoadingStadiumButton(
        idleStateWidget: Text('Create'),
        onPressed: () => _createTodo(household),
      ),
    );
  }

  Widget _buildEditableRow(
      String label, TextEditingController controller, FocusNode focusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label:', style: _labelTextStyle),
            if (editable)
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => focusNode.requestFocus(),
              ),
          ],
        ),
        EditableText(
          maxLines: null,
          controller: controller,
          focusNode: focusNode,
          style: _editableTextStyle,
          cursorColor: Colors.grey,
          backgroundCursorColor: Colors.amber,
          readOnly: !editable,
          autofocus: editTodo == null,
        )
      ],
    );
  }

  Widget _buildDescriptionRow() {
    return _buildEditableRow(
        'Description', _descriptionController, _editableTextFocusNode);
  }

  Widget _buildTitleRow() {
    return _buildEditableRow(
        'Title', _titleController, _editableTextFocusNodeTitle);
  }

  Widget _buildDeadlineRow() {
    return Row(children: [
      Flexible(
        child: TextField(
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today),
            labelText: "Deadline:",
            hintText: 'Choose deadline',
          ),
          readOnly: !editable,
          controller: _dateController,
          onTap: () {
            if (editable) {
              Utility.pickDate(context, _dateController);
            }
          },
        ),
      ),
      if (editable)
        IconButton(
          onPressed: () => Utility.pickDate(context, _dateController),
          icon: Icon(Icons.edit),
        )
    ]);
  }

  Widget _buildAssigneeRow(List<User> members) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Todo for:',
        hintText: 'Choose member',
      ),
      value: _selectedMemberId ?? userService.getUser!.id,
      items: [
        for (final member in members)
          DropdownMenuItem<String>(
            value: member.id,
            child: Text(member.name),
          ),
      ],
      onChanged: !editable
          ? null
          : (String? value) {
              if (value != null) {
                setState(() {
                  _selectedMemberId = value;
                });
              }
            },
    );
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
          editTodo!.creator.name,
          style: _editableTextStyle,
        )
      ],
    );
  }

  Widget _buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LoadingStadiumButton(
            idleStateWidget: Text('Delete'), onPressed: _deleteTodo),
        LoadingStadiumButton(
            idleStateWidget: Text('Save'), onPressed: _updateTodo)
      ],
    );
  }

  void _updateTodo() async {
    String? errorMessage = _validateInputs();
    if (errorMessage != null) {
      return showTopSnackBar(context, errorMessage, Colors.red);
    }

    final updatedTodo = editTodo!.todo.copyWith(
      description: _descriptionController.text,
      title: _titleController.text,
      deadline: Timestamp.fromDate(Utility.parseDate(_dateController.text)),
    );

    await Utility.performActionAndShowInfo(
      context: context,
      action: () async {
        if (editTodo!.todo.createdForId != _selectedMemberId) {
          await userService.addNotification(
            _selectedMemberId!,
            NotificationType.todoAssigned,
            'New TODO assigned.',
            'User ${userService.getUser!.name} assigned you new TODO. Deadline: ${Utility.formatDate(updatedTodo.deadline.toDate())}.',
            updatedTodo.id,
          );
          await userService.addNotification(
            editTodo!.todo.createdForId,
            NotificationType.todoUpdated,
            'TODO Reassigned.',
            'TODO ${editTodo!.todo.title} was re-assigned to different user ${userService.getUser!.name}.',
            updatedTodo.id,
          );
        }
        await userService.addNotification(
          editTodo!.todo.createdForId,
          NotificationType.todoUpdated,
          'TODO Updated.',
          'TODO ${editTodo!.todo.title} wa updated!',
          updatedTodo.id,
        );
        return todoService.updateTodo(updatedTodo);
      },
      successMessage: 'Todo updated.',
    );

    Modular.to.popAndPushNamed(AppRoute.myTodos.path);
  }

  void _deleteTodo() async {
    final updatedTodo = editTodo!.todo.copyWith(
      deletedAt: Timestamp.fromDate(DateTime.now()),
    );

    final res = await Utility.showConfirmationDialog(
      context,
      'Delete',
      'Delete todo?',
    );

    if (res == true && mounted) {
      await Utility.performActionAndShowInfo(
        context: context,
        action: () async {
          await GetIt.instance<UserService>().addNotification(
            updatedTodo.createdById,
            NotificationType.todoDeleted,
            'TODO was deleted',
            'TODO ${updatedTodo.title} was deleted!',
            null,
          );

          await todoService.updateTodo(updatedTodo);
          return null;
        },
        successMessage: 'Todo deleted.',
      );
    }

    Modular.to.popAndPushNamed(AppRoute.myTodos.path);
  }

  void _createTodo(Household household) async {
    String? errorMessage = _validateInputs();
    if (errorMessage != null) {
      return showTopSnackBar(context, errorMessage, Colors.red);
    }

    final todo = await todoService.createTodo(
      _selectedMemberId!,
      Utility.parseDate(_dateController.text),
      _descriptionController.text,
      _titleController.text,
      household.id,
    );

    if (userService.getUser!.id != todo.createdForId) {
      await userService.addNotification(
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
    if (_selectedMemberId == null) {
      return 'Please choose member';
    }

    if (_descriptionController.text.isEmpty) {
      return 'Please provide description';
    }

    if (_dateController.text.isEmpty) {
      return 'Please choose deadline';
    }

    if (_titleController.text.isEmpty) {
      return 'Please provide title.';
    }

    return null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _editableTextFocusNode.dispose();
    super.dispose();
  }
}
