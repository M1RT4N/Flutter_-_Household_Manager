import 'package:flutter/foundation.dart'; // Added import
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/pages/common/static_page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/utils/routing/routes.dart';
import 'package:household_manager/widgets/info_bubble.dart';
import 'package:household_manager/widgets/loading_stadium_button.dart';
import 'package:household_manager/widgets/snack_bar.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart'; // Added import

const _mainBoxSize = 600.0;
const _mainBoxPadding = 20.0;
const _gapBetweenColumns = 20.0;
const _boxHeight = 250.0;
const _boxWidth = 300.0;
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
  final _householdService = GetIt.instance<HouseholdService>();

  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return StaticPageTemplate(
      title: 'Join Household',
      showDrawer: false,
      showBackArrow: true,
      showNotifications: false,
      bodyFunction: _isScanning ? _buildQRScanner : _buildMainContent,
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(_mainBoxPadding),
        constraints: BoxConstraints(maxWidth: _mainBoxSize),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InfoBubble(
                labelText:
                    'Please obtain the household code from the household member, or scan the QR code.',
              ),
              SizedBox(height: _gapBetweenColumns),
              _buildForm(),
              SizedBox(height: _gapBetweenColumns),
              _buildScanQRCodeButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SizedBox(
      width: _boxWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Enter Code',
                prefixIcon: Icon(Icons.home),
              ),
              controller: _codeController,
            ),
          ),
          SizedBox(height: _gapBetweenColumns),
          LoadingStadiumButton(
            idleStateWidget: Text(
              'Join',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: _joinHousehold,
          )
        ],
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
                  'Scan QRCode',
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
    final code = _codeController.text.trim();
    if (!_isValidCode(code)) {
      showTopSnackBar(
          context, 'Please enter a valid 8-character code.', Colors.red);
      return;
    }

    String? errorMessage = await _householdService.createHouseholdRequest(code);
    if (errorMessage != null) {
      if (mounted) {
        showTopSnackBar(context, errorMessage, Colors.red);
      }
      return;
    }

    if (mounted) {
      showTopSnackBar(context, 'Request created successfully.', Colors.green);
    }

    _navigateToHouseholdRequestPage();
  }

  bool _isValidCode(String code) {
    return code.isNotEmpty && code.length == _householdService.codeLength;
  }

  void _navigateToHouseholdRequestPage() {
    Modular.to.navigate(
      AppRoute.householdRequest.path,
      arguments: {'hideAppBar': false},
    );
  }

  void _scanQRCode() async {
    if (kIsWeb) {
      showTopSnackBar(
          context, 'QR code scanning is not supported on web.', Colors.red);
      return;
    }

    setState(() {
      _isScanning = true;
    });
  }

  Widget _buildQRScanner(BuildContext context) {
    return Scaffold(
      body: QRCodeDartScanView(
        typeScan: TypeScan.live,
        intervalScan: const Duration(seconds: 1),
        takePictureButtonBuilder: (context, controller, isLoading) {
          return ElevatedButton(
            onPressed: controller.takePictureAndDecode,
            child: Text('Take a picture'),
          );
        },
        formats: [
          BarcodeFormat.qrCode,
        ],
        onCapture: (Result result) {
          _codeController.text = result.text;
          _joinHousehold();
        },
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
