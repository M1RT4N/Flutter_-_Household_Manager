import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/household_dto.dart';
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

  Future<HouseholdDto> fetchUsers(Household household) async {
    return HouseholdDto(
      household: household,
      members: await _userService.getUsersByIds(household.members),
      requesters: await _userService.getUsersByIds(household.requested),
    );
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

    final household = getHousehold!;
    final user = _userService.getUser!;

    final newHousehold =
        household.copyWith(requested: household.requested..add(user.id));
    final newUser = user.copyWith(requestedId: household.id);

    return await _householdUserUpdateTransaction(newHousehold, newUser);
  }

  Future<String?> cancelHouseholdRequest() async {
    final user = _userService.getUser!;
    final household = await _householdRepository.getDocument(user.requestedId!);

    final newHousehold = household!.copyWith(
      requested: household.requested..remove(user.id),
    );
    final newUser = user.copyWith(requestedId: '');

    return await _householdUserUpdateTransaction(newHousehold, newUser,
        pushToStream: false);
  }

  Future<String?> tryLeaveHousehold() async {
    try {
      final user = _userService.getUser!;
      final household = getHousehold!;

      final newUser = user.copyWith(householdId: '');
      final newHousehold = household.copyWith(
        members: household.members..remove(user.id),
      );

      final result =
          await _householdUserUpdateTransaction(newHousehold, newUser);

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
      final newUser = user.copyWith(householdId: household.id);

      return await _householdUserUpdateTransaction(household, newUser);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> renameHousehold(String newName) async {
    _setHousehold(getHousehold!.copyWith(name: newName));
    return null;
  }

  Future<void> logout() async {
    _pushToSteam(null);
    await _userService.logout();
  }

  Future<void> _setHousehold(Household household) async {
    await _householdRepository.setOrAdd(household.id, household);
    _pushToSteam(household);
  }

  Future<String?> approveJoinRequest(String householdId, User? user) async {
    final household = await fetchHousehold(householdId);
    if (household == null || user == null) {
      return "Could not fetch household.";
    }

    final newHousehold = household.copyWith(
      requested: household.requested..remove(user.id),
      members: household.members..add(user.id),
    );
    final newUser = user.copyWith(
      householdId: householdId,
      requestedId: "",
    );

    final error = await _householdUserUpdateTransaction(newHousehold, newUser);
    if (error != null) {
      return error;
    }

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

    return null;
  }

  Future<String?> rejectJoinRequest(String householdId, User? user) async {
    final household = await fetchHousehold(householdId);
    if (household == null || user == null) {
      return "Could not fetch household.";
    }

    final newHousehold = household.copyWith(
      requested: household.requested..remove(user.id),
    );
    final newUser = user.copyWith(
      householdId: "",
      requestedId: "",
    );

    final error = await _householdUserUpdateTransaction(newHousehold, newUser);
    if (error != null) {
      return error;
    }

    for (final memberId in household.members) {
      await _userService.addNotification(
        memberId,
        NotificationType.userRejected,
        'Join Request Rejected',
        'A join request for ${user.name} has been rejected.',
        null,
      );
    }

    return null;
  }

  Future<String?> removeMember(String member) async {
    final household = getHousehold!;
    final user = await _userService.getById(member);

    final members = List<String>.from(household.members)..remove(member);

    final newUser = user!.copyWith(householdId: '');
    final newHousehold = household.copyWith(members: members);

    return await _householdUserUpdateTransaction(newHousehold, newUser);
  }

  Future<String?> _householdUserUpdateTransaction(
      Household newHousehold, User newUser,
      {bool pushToStream = true}) async {
    final householdDoc = _householdRepository.reference.doc(newHousehold.id);
    final userDoc = _userService.getUserDoc(newUser);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(householdDoc, newHousehold);
        tx.set(userDoc, newUser);

        if (pushToStream) {
          _pushToSteam(newHousehold);
        }
      });
    } catch (e) {
      return e.toString();
    }

    return null;
  }
}
