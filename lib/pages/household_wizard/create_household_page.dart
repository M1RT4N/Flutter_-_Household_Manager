// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_loading_button/easy_loading_button.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:household_manager/models/user.dart';
// import 'package:household_manager/services/household_service.dart';
// import 'package:household_manager/services/user_service.dart';
// import 'package:household_manager/widgets/snack_bar.dart';
//
// const _mainBoxSize = 400.0;
// const _mainBoxPadding = 16.0;
// const _spaceAfterField = 30.0;
//
// class CreateHouseholdPage extends StatefulWidget {
//   final householdService = GetIt.instance<HouseholdService>();
//   final userService = GetIt.instance<UserService>();
//
//   CreateHouseholdPage({super.key});
//
//   @override
//   State<CreateHouseholdPage> createState() => _CreateHouseholdPageState();
// }
//
// class _CreateHouseholdPageState extends State<CreateHouseholdPage> {
//   final _householdNameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Household'),
//       ),
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.all(_mainBoxPadding),
//           constraints: BoxConstraints(maxWidth: _mainBoxSize),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildHouseholdNameField(),
//               SizedBox(height: _spaceAfterField),
//               EasyButton(
//                 idleStateWidget: Text('Create'),
//                 loadingStateWidget: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).primaryColor,
//                   ),
//                 ),
//                 onPressed: () =>
//                     _createHousehold(_householdNameController.text),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHouseholdNameField() {
//     return TextField(
//       decoration: InputDecoration(
//         labelText: 'Household Name',
//         prefixIcon: Icon(Icons.home),
//       ),
//       controller: _householdNameController,
//     );
//   }
//
//   void _createHousehold(String householdName) async {
//     if (householdName.isEmpty) {
//       showTopSnackBar(context, 'Household name is required.', Colors.red);
//       return;
//     }
//
//     try {
//       String householdId =
//           await widget.householdService.createHousehold(householdName);
//
//       await widget.userService.fetchUserProfile();
//
//       if (widget.userService.userStream != null) {
//         User user = widget.userService.userStream!;
//         String userId = user.id;
//
//         await FirebaseFirestore.instance.collection('users').doc(userId).set({
//           'householdId': householdId,
//         }, SetOptions(merge: true));
//
//         await widget.userService.fetchUserProfile();
//
//         if (mounted) {
//           Navigator.pushReplacementNamed(
//               context,
//               widget.userService.householdId != null &&
//                       widget.userService.householdId!.isNotEmpty
//                   ? '/home'
//                   : '/choose_household');
//         }
//         return;
//       }
//
//       if (mounted) {
//         showTopSnackBar(context, 'User profile not found.', Colors.red);
//       }
//     } catch (e) {
//       if (mounted) {
//         showTopSnackBar(context, 'Failed to create household: $e', Colors.red);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _householdNameController.dispose();
//     super.dispose();
//   }
// }
