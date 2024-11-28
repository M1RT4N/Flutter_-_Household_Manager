import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _buttonWidth = 120.0;
const _buttonHeight = 40.0;
const _mainBoxSize = 400.0;
const _mainBoxPadding = 16.0;
const _spaceAfterField = 30.0;

class CreateHouseholdPage extends StatefulWidget {
  final householdService = GetIt.instance<HouseholdService>();
  final userService = GetIt.instance<UserService>();

  CreateHouseholdPage({super.key});

  @override
  State<CreateHouseholdPage> createState() => _CreateHouseholdPageState();
}

class _CreateHouseholdPageState extends State<CreateHouseholdPage> {
  final _householdNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Household'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(_mainBoxPadding),
          constraints: BoxConstraints(maxWidth: _mainBoxSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHouseholdNameField(),
              SizedBox(height: _spaceAfterField),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHouseholdNameField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Household Name',
        prefixIcon: Icon(Icons.home),
      ),
      controller: _householdNameController,
    );
  }

  Widget _buildCreateButton() {
    return EasyButton(
        idleStateWidget: SizedBox(
          width: _buttonWidth,
          height: _buttonHeight,
          child: ElevatedButton(
            onPressed: _createHousehold,
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
            ),
            child: Text('Create'),
          ),
        ),
        loadingStateWidget: SizedBox(
          width: _buttonWidth,
          height: _buttonHeight,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
        ));
  }

  void _createHousehold() async {
    String householdName = _householdNameController.text;
    if (householdName.isEmpty) {
      return showTopSnackBar(
          context, 'Household name is required.', Colors.red);
    }

    await widget.householdService
        .tryCreateHousehold(householdName, widget.userService.getUser!);

    if (mounted) {
      showTopSnackBar(context, 'Household created successfully.', Colors.green);
      Modular.to.navigate('/home');
    }
  }

  @override
  void dispose() {
    _householdNameController.dispose();
    super.dispose();
  }
}
