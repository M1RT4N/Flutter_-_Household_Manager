import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/database_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

const _codeLength = 8;
const _householdIdLength = 20;

class HouseholdService {
  final _householdStream = BehaviorSubject<Household?>.seeded(null);
  final DatabaseService<Household> _householdRepository;
  final UserService _userService;

  Stream<Household?> get getHouseholdStream => _householdStream.stream;

  Household? get getHousehold => _householdStream.value;

  HouseholdService(this._householdRepository, this._userService);

  int get codeLength => _codeLength;

  void _pushToSteam(Household? household) {
    _householdStream.value = household;
  }

  Future<Household?> fetchHousehold(String id) async {
    var household = await _householdRepository.getDocument(id);
    _pushToSteam(household);
    return household;
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

    return await _householdRequestTransaction(
        householdDoc.reference, household, user);
  }

  Future<String?> _householdRequestTransaction(
      DocumentReference<Household> householdDocRef,
      Household newHousehold,
      User newUser) async {
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(householdDocRef, newHousehold.toJson());
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

    return await _householdRequestTransaction(
        householdDoc.reference, household, user);
  }

  Future<String?> tryLeaveHousehold() async {
    try {
      var snapshot = await _getHouseholdByCode(getHousehold!.code);
      if (snapshot.docs.isEmpty) {
        return 'Household not found.';
      }

      var user = _userService.getUser!;
      user = user.copyWith(householdId: null);
      var householdDoc = snapshot.docs.first;
      var household = householdDoc.data();
      household =
          household.copyWith(members: household.members..remove(user.id));
      return _householdRequestTransaction(
          householdDoc.reference, household, user);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> tryCreateHousehold(String householdName) async {
    var user = _userService.getUser!;
    var household = Household(
        id: Utility.generateRandomCode(_householdIdLength),
        name: householdName,
        code: Utility.generateRandomCode(_codeLength),
        members: [user.id],
        requested: [],
        createdAt: Timestamp.now());
    var householdDoc = _householdRepository.reference.doc(household.id);
    user = user..copyWith(householdId: household.id);

    return await _householdRequestTransaction(householdDoc, household, user);
  }
}
