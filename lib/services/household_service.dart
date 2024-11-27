import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:household_manager/models/household.dart';
import 'package:rxdart/rxdart.dart';

class HouseholdService {
  final _householdStream = BehaviorSubject<Household?>.seeded(null);

  Stream<Household?> get getHouseholdStream => _householdStream.stream;

  Future<String> createHousehold(String householdName) async {
    String code = _generateRandomCode();
    var docRef = fb.FirebaseFirestore.instance.collection('households').doc();
    String householdId = docRef.id;

    Household household = Household(
      id: householdId,
      name: householdName,
      code: code,
      members: [FirebaseAuth.instance.currentUser!.uid],
      requested: [],
      createdAt: fb.Timestamp.now(),
    );

    await docRef.set(household.toJson());
    return householdId;
  }

  Future<bool> joinHouseholdByCode(String code) async {
    fb.QuerySnapshot query = await fb.FirebaseFirestore.instance
        .collection('households')
        .where('code', isEqualTo: code)
        .get();

    if (query.docs.isEmpty) {
      return false;
    }

    var householdDoc = query.docs.first;
    Household household =
        Household.fromJson(householdDoc.data() as Map<String, dynamic>);

    await fb.FirebaseFirestore.instance
        .collection('households')
        .doc(household.id)
        .update({
      'requested':
          fb.FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });

    await fb.FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'requestedId': household.id,
    });

    return true;
  }

  Future<bool> cancelHouseholdRequestByCode(String code) async {
    var query = await fb.FirebaseFirestore.instance
        .collection('households')
        .where('code', isEqualTo: code)
        .get();

    if (query.docs.isEmpty) {
      return false;
    }

    var householdDoc = query.docs.first;
    Household household =
        Household.fromJson(householdDoc.data() as Map<String, dynamic>);

    await fb.FirebaseFirestore.instance
        .collection('households')
        .doc(household.id)
        .update({
      'requested':
          fb.FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });

    return true;
  }

  // Future<Household?> getHousehold(User user) async {
  //   if (user.householdId != null) {
  //     try {
  //       final householdDoc = await fb.FirebaseFirestore.instance
  //           .collection('households')
  //           .doc(user.householdId)
  //           .get();
  //       if (householdDoc.exists) {
  //         return Household.fromJson(householdDoc.data()!);
  //       }
  //       // ignore: empty_catches
  //     } catch (e) {}
  //   }
  //   return null;
  // }
  //
  // Future<void> leaveHousehold() async {
  //   final userService = GetIt.instance<UserService>();
  //   final userProfile = await userService.getUserProfile();
  //   final userId = userProfile.id;
  //   final householdId = userService.householdId;
  //
  //   if (householdId != null) {
  //     await _removeUserFromHousehold(userId, householdId);
  //     await userService.updateUserProfile({'householdId': null});
  //     userService.setUser({
  //       ...userService.userStream!,
  //       'householdId': null,
  //     }, userId);
  //   }
  // }

  Future<void> _removeUserFromHousehold(
      String userId, String householdId) async {
    var householdRef =
        fb.FirebaseFirestore.instance.collection('households').doc(householdId);
    var userRef = fb.FirebaseFirestore.instance.collection('users').doc(userId);

    await fb.FirebaseFirestore.instance.runTransaction((transaction) async {
      var householdSnapshot = await transaction.get(householdRef);
      if (householdSnapshot.exists) {
        List<dynamic> members = householdSnapshot.get('members');
        members.remove(userId);
        transaction.update(householdRef, {'members': members});
      }
      transaction.update(userRef, {'householdId': null});
    });
  }

  String _generateRandomCode() {
    var ukey = UniqueKey();
    var str = ukey.toString();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        8,
        (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) %
            chars.length]).join();
  }
}
