import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:household_manager/common/database_service.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:rxdart/rxdart.dart';

const _codeLength = 8;

class HouseholdService {
  final _householdStream = BehaviorSubject<Household?>.seeded(null);
  final DatabaseService<Household> _householdRepository;
  final UserService _userService;

  Stream<Household?> get getHouseholdStream => _householdStream.stream;

  Household? get getHousehold => _householdStream.value;

  HouseholdService(this._householdRepository, this._userService);

  void _pushToSteam(Household household) {
    _householdStream.value = household;
  }

  Future<void> setHousehold(Household household) async {
    await _updateHouseholdInRepository(household);
    _pushToSteam(household);
  }

  Future<void> _updateHouseholdInRepository(Household household) {
    return _householdRepository.setOrAdd(household.id, household);
  }

  Future<String?> createHouseholdRequest(String code) async {
    var householdByCode = await _getHouseholdByCode(code);

    if (householdByCode.docs.isEmpty) {
      return 'Invalid household code.';
    }

    var user = _userService.getUser!;
    var householdDoc = householdByCode.docs.first;
    var household = householdDoc.data();

    household =
        household.copyWith(requested: household.requested..add(user.id));
    user = user.copyWith(requestedId: household.id);

    return await _householdRequestTransaction(householdDoc, household, user);
  }

  Future<String?> _householdRequestTransaction(
      QueryDocumentSnapshot<Household> householdDoc,
      Household newHousehold,
      User newUser) async {
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.update(householdDoc.reference, newHousehold.toJson());
        tx.update(_userService.getUserDoc, newUser.toJson());
      });
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  Future<QuerySnapshot<Household>> _getHouseholdByCode(String code) {
    return _householdRepository.reference
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
  }

  Future<String?> cancelHouseholdRequest() async {
    var user = _userService.getUser!;
    var householdByCode = await _getHouseholdByCode(user.requestedId!);

    if (householdByCode.docs.isEmpty) {
      return 'Invalid household code';
    }

    var householdDoc = householdByCode.docs.first;
    var household = householdDoc.data();

    household =
        household.copyWith(requested: household.requested..remove(user.id));
    user = user..copyWith(requestedId: null);

    return await _householdRequestTransaction(householdDoc, household, user);
  }

  // Future<String?> tryLeaveHousehold() async {
  //   try {
  //     await _householdService.cancelHouseholdRequest(householdId);
  //     await _userService
  //         .updateUserProfile({'requestedId': FieldValue.delete()});
  //     _userService.setUserProfile({
  //       ..._userService.userProfile!.toMap(),
  //       'requestedId': null,
  //     }, _userService.userProfile!.id);
  //
  //     if (context.mounted) {
  //       showTopSnackBar(
  //           context, 'Request cancelled successfully.', Colors.green);
  //       Modular.to.navigate('/choose_household');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       showTopSnackBar(context, 'Failed to cancel request: $e', Colors.red);
  //     }
  //   }
  // }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        8,
        (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) %
            chars.length]).join();
  }

  Future<void> tryCreateHousehold(String householdName, User user) async {
    await setHousehold(Household(
        id: UniqueKey().toString(),
        name: householdName,
        code: nanoid(length: _codeLength),
        members: [user.id],
        requested: [],
        createdAt: Timestamp.now()));
  }
}
