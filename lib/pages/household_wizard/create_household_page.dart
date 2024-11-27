import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _buttonWidth = 120.0;
const _buttonHeight = 40.0;
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
  bool _isCreating = false;

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
    return _isCreating
        ? SizedBox(
            width: _buttonWidth,
            height: _buttonHeight,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          )
        : SizedBox(
            width: _buttonWidth,
            height: _buttonHeight,
            child: ElevatedButton(
              onPressed: _createHousehold,
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
              ),
              child: Text('Create'),
            ),
          );
  }

  void _createHousehold() async {
    String householdName = _householdNameController.text;
    if (householdName.isEmpty) {
      showTopSnackBar(context, 'Household name is required.', Colors.red);
      return;
    }
    setState(() {
      _isCreating = true;
    });

    final householdService = GetIt.instance<HouseholdService>();
    final userService = GetIt.instance<UserService>();

    try {
      String householdId =
          await householdService.createHousehold(householdName);

      await userService.fetchUserProfile();

      if (userService.userProfile != null) {
        ProfileInfo userProfile = userService.userProfile!;
        String userId = userProfile.id;

        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'householdId': householdId,
        }, SetOptions(merge: true));

        await userService.fetchUserProfile();

        setState(() {
          _isCreating = false;
        });

        if (mounted) {
          Modular.to.navigate(userService.householdId != null &&
                  userService.householdId!.isNotEmpty
              ? AppRoute.home.path
              : AppRoute.chooseHousehold.path);
        }
        return;
      }

      setState(() {
        _isCreating = false;
      });
      if (mounted) {
        showTopSnackBar(context, 'User profile not found.', Colors.red);
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      if (mounted) {
        showTopSnackBar(context, 'Failed to create household: $e', Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _householdNameController.dispose();
    super.dispose();
  }
}
