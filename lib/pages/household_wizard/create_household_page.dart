import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/pages/common/test_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _mainBoxSize = 400.0;
const _mainBoxPadding = 16.0;
const _spaceAfterField = 30.0;

class CreateHouseholdPage extends StatefulWidget {
  const CreateHouseholdPage({super.key});

  @override
  State<CreateHouseholdPage> createState() => _CreateHouseholdPageState();
}

class _CreateHouseholdPageState extends State<CreateHouseholdPage> {
  final _householdNameController = TextEditingController();
  final _householdService = GetIt.instance<HouseholdService>();

  @override
  Widget build(BuildContext context) {
    return TestPageTemplate(
      title: 'Create Household',
      showDrawer: false,
      showBackArrow: true,
      showNotifications: false,
      bodyFunction: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context, AppState appState) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(_mainBoxPadding),
        constraints: BoxConstraints(maxWidth: _mainBoxSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHouseholdNameField(),
            SizedBox(height: _spaceAfterField),
            LoadingStadiumButton(
                buttonText: 'Create', onPressed: _createHousehold),
          ],
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

  void _createHousehold() async {
    String householdName = _householdNameController.text;
    if (householdName.isEmpty) {
      return showTopSnackBar(
          context, 'Household name is required.', Colors.red);
    }

    var errorMessage =
        await _householdService.tryCreateHousehold(householdName);
    if (errorMessage != null) {
      if (mounted) {
        return showTopSnackBar(context, errorMessage, Colors.red);
      }
    }

    if (mounted) {
      showTopSnackBar(context, 'Household created successfully.', Colors.green);
      Modular.to.navigate(AppRoute.home.path);
    }
  }

  @override
  void dispose() {
    _householdNameController.dispose();
    super.dispose();
  }
}
