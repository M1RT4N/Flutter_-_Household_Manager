import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/snack_bar.dart';

const _mainBoxSize = 600.0;
const _mainBoxPadding = 16.0;
const _gapBetweenColumns = 20.0;
const _codeLength = 8; // In symbols
const _buttonWidth = 120.0;
const _buttonHeight = 40.0;
const _infoBoxPadding = 12.0;
const _infoBoxRadius = 8.0;
const _boxHeight = 150.0;
const _boxWidth = 250.0;
const _qrCodeIconSize = 40.0;
const _qrCodeTextPadding = 8.0;
const _qrCodeTextSize = 16.0;
const _qrCodePadding = 16.0;

class JoinHouseholdPage extends StatefulWidget {
  const JoinHouseholdPage({super.key});

  @override
  State<JoinHouseholdPage> createState() => _JoinHouseholdPageState();
}

class _JoinHouseholdPageState extends State<JoinHouseholdPage> {
  final _codeController = TextEditingController();
  final HouseholdService _householdService = HouseholdService();
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add to Household'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(_mainBoxPadding),
          constraints: BoxConstraints(maxWidth: _mainBoxSize),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildInfoBox(),
                SizedBox(height: _gapBetweenColumns),
                _buildFormAndScanRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(_infoBoxPadding),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(_infoBoxRadius),
      ),
      child: Text(
        'Please obtain the household code from the household member, or scan the QR code.',
        style: TextStyle(color: Colors.blue),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFormAndScanRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildForm()),
        SizedBox(width: _gapBetweenColumns * 2),
        _buildScanQRCodeButton(),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Household Code',
            prefixIcon: Icon(Icons.home),
          ),
          controller: _codeController,
        ),
        SizedBox(height: _gapBetweenColumns),
        _isJoining ? _buildLoadingIndicator() : _buildJoinButton(),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: _buttonWidth,
      height: _buttonHeight,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return SizedBox(
      width: _buttonWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: _joinHousehold,
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
        ),
        child: Text('Join'),
      ),
    );
  }

  Widget _buildScanQRCodeButton() {
    return Column(
      children: [
        SizedBox(
          width: _boxWidth,
          height: _boxHeight,
          child: ElevatedButton(
            onPressed: _scanQRCode,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(_qrCodePadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.qr_code, size: _qrCodeIconSize),
                SizedBox(height: _qrCodeTextPadding),
                Text(
                  'Scan QRcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: _qrCodeTextSize),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _joinHousehold() async {
    String code = _codeController.text.trim();
    if (!_isValidCode(code)) {
      showTopSnackBar(
          context, 'Please enter a valid 8-character code.', Colors.red);
      return;
    }

    setState(() {
      _isJoining = true;
    });

    bool success = await _householdService.joinHouseholdByCode(code);
    if (!success) {
      _handleJoinFailure('Invalid code.');
      return;
    }

    final userService = GetIt.instance<UserService>();
    ProfileInfo? userProfile = await userService.getUserProfile();

    await _updateUserProfile(userProfile.id, code);

    if (mounted) {
      showTopSnackBar(context, 'Request created successfully.', Colors.green);
    }
    _navigateToHouseholdRequestPage();
  }

  Future<void> _updateUserProfile(String userId, String householdCode) async {
    final userService = GetIt.instance<UserService>();
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('households')
          .where('code', isEqualTo: householdCode)
          .get();

      if (query.docs.isNotEmpty) {
        String householdId = query.docs.first.id;
        await userService.updateUserProfile({'requestedId': householdId});
        userService.setUserProfile({
          ...userService.userProfile!.toMap(),
          'householdId': null,
        }, userService.userProfile!.id);
      } else {
        _handleJoinFailure('Household not found.');
      }
    } catch (e) {
      _handleJoinFailure('Failed to update user profile: ${e.toString()}');
    }
  }

  bool _isValidCode(String code) {
    return code.isNotEmpty && code.length == _codeLength;
  }

  void _handleJoinFailure(String message) {
    setState(() {
      _isJoining = false;
    });
    showTopSnackBar(context, message, Colors.red);
    _navigateToChooseHouseholdPage();
  }

  void _navigateToHouseholdRequestPage() {
    setState(() {
      _isJoining = false;
    });

    Modular.to.navigate(
      '/household_request',
      arguments: {'hideAppBar': false},
    );
  }

  void _navigateToChooseHouseholdPage() {
    Modular.to.navigate(
      '/choose_household',
    );
  }

  void _scanQRCode() {
    // TODO: Implement QR code scanning functionality
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
