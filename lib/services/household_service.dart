import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/database_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/utils/notifications/notification_type.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

const _codeLength = 8;
const _householdIdLength = 20;

class HouseholdService {
  final _householdStream = BehaviorSubject<Household?>.seeded(null);
  final DatabaseService<Household> _householdRepository;
  final UserService _userService;

  HouseholdService(this._householdRepository, this._userService);

  Stream<Household?> get getHouseholdStream {
    final id = _userService.getUser!.householdId;
    if (id == null) {
      return Stream<Household?>.value(null);
    }
    return _householdRepository.observeDocument(id);
  }

  Household? get getHousehold => _householdStream.value;

  int get codeLength => _codeLength;

  void _pushToSteam(Household? household) {
    _householdStream.value = household;
  }

  Future<Household?> _fetchHouseholdByCode(String code) async {
    final repo = await _householdRepository.reference
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    final householdId = repo.docs.first.data().id;
    return fetchHousehold(householdId);
  }

  Future<Household?> fetchHousehold(String id) async {
    final household = await _householdRepository.getDocument(id);
    _pushToSteam(household);
    return household;
  }

  Future<String?> createHouseholdRequest(String code) async {
    final householdByCode = await _fetchHouseholdByCode(code);

    if (householdByCode == null) {
      return 'Invalid household code.';
    }

    final user = _userService.getUser!;
    final householdDoc = _householdRepository.reference.doc(householdByCode.id);
    final household = getHousehold!;

    final newHousehold =
        household.copyWith(requested: household.requested..add(user.id));
    final newUser = user.copyWith(requestedId: household.id);

    return await _householdRequestTransaction(
        householdDoc, newHousehold, newUser);
  }

  Future<String?> _householdRequestTransaction(
      DocumentReference<Household> householdDocRef,
      Household newHousehold,
      User newUser) async {
    try {
      await _setHousehold(newHousehold);
      await _userService.setUser(newUser);
    } catch (e) {
      return e.toString();
    }
    return null;
  }

  Future<String?> cancelHouseholdRequest() async {
    final user = _userService.getUser!;
    final household = await _householdRepository.getDocument(user.requestedId!);
    final householdDoc = _householdRepository.reference.doc(household!.id);

    final newHousehold =
        household.copyWith(requested: household.requested..remove(user.id));
    final newUser = user.copyWith(requestedId: '');

    return await _householdRequestTransaction(
        householdDoc, newHousehold, newUser);
  }

  Future<String?> tryLeaveHousehold() async {
    try {
      final user = _userService.getUser!;
      final newUser = user.copyWith(householdId: '');
      final household = getHousehold!;
      final householdDoc = _householdRepository.reference.doc(household.id);
      final newHousehold =
          household.copyWith(members: household.members..remove(user.id));
      final result = await _householdRequestTransaction(
          householdDoc, newHousehold, newUser);

      for (final memberId in household.members) {
        if (memberId != user.id) {
          await _userService.addNotification(
            memberId,
            NotificationType.userLeft,
            'Household Member Left',
            'A member ${user.name} has left the household.',
            null,
          );
        }
      }

      return result;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> tryCreateHousehold(String householdName) async {
    try {
      final user = _userService.getUser!;
      final household = Household(
        id: Utility.generateRandomCode(_householdIdLength),
        name: householdName,
        code: Utility.generateRandomCode(_codeLength),
        members: [user.id],
        requested: [],
        createdAt: Timestamp.now(),
      );
      final householdDoc = _householdRepository.reference.doc(household.id);
      final newUser = user.copyWith(householdId: household.id);

      return await _householdRequestTransaction(
          householdDoc, household, newUser);
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> renameHousehold(String newName) async {
    _setHousehold(getHousehold!.copyWith(name: newName));
  }

  Future<void> logout() async {
    await _userService.logout();
    _pushToSteam(null);
  }

  Future<void> _setHousehold(Household household) async {
    await _householdRepository.setOrAdd(household.id, household);
    _pushToSteam(household);
  }

  Future<void> approveJoinRequest(String householdId, User? user) async {
    final household = await fetchHousehold(householdId);
    if (household == null || user == null) return;

    final newHousehold = household.copyWith(
      requested: household.requested..remove(user.id),
      members: household.members..add(user.id),
    );

    await setHousehold(newHousehold);
    await _userService.joinHousehold(user.id, householdId);

    for (final memberId in household.members) {
      if (memberId != user.id) {
        await _userService.addNotification(
          memberId,
          NotificationType.userJoined,
          'Join Request Accepted',
          'A new member ${user.name}  has joined the household.',
          null,
        );
      }
    }
  }

  Future<void> rejectJoinRequest(String householdId, User? user) async {
    final household = await fetchHousehold(householdId);
    if (household == null || user == null) return;

    final newHousehold = household.copyWith(
      requested: household.requested..remove(user.id),
    );

    await setHousehold(newHousehold);
    await _userService.joinHousehold(user.id, "");

    for (final memberId in household.members) {
      await _userService.addNotification(
        memberId,
        NotificationType.userRejected,
        'Join Request Rejected',
        'A join request for ${user.name} has been rejected.',
        null,
      );
    }
  }

  Future<void> manageRequest(String request, bool accept) async {
    final household = getHousehold!;
    final user = await _userService.getById(request);

    final newUser = user!
        .copyWith(requestedId: '', householdId: accept ? household.id : null);

    final requests = List<String>.from(household.requested)..remove(request);
    final members = List<String>.from(household.members)..add(user.id);

    final newHousehold = household.copyWith(
        requested: accept ? requests : null, members: accept ? members : null);

    _userService.updateUser(newUser);
    _setHousehold(newHousehold);
  }

  Future<void> removeMember(String member) async {
    final household = getHousehold!;
    final user = await _userService.getById(member);
    final newUser = user!.copyWith(householdId: '');
    final members = List<String>.from(household.members)..remove(member);
    final newHousehold = household.copyWith(members: members);
    _userService.updateUser(newUser);
    _setHousehold(newHousehold);
  }
}
