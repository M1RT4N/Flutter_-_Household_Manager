import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/services/user_service.dart';

class HouseholdService {
  Future<String> createHousehold(String householdName) async {
    String code = _generateRandomCode();
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('households').doc();
    String householdId = docRef.id;

    Household household = Household(
      id: householdId,
      name: householdName,
      code: code,
      members: [FirebaseAuth.instance.currentUser!.uid],
      requested: [],
      createdAt: Timestamp.now(),
    );

    await docRef.set(household.toJson());
    return householdId;
  }

  Future<bool> joinHouseholdByCode(String code) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('households')
        .where('code', isEqualTo: code)
        .get();

    if (query.docs.isEmpty) {
      return false;
    }

    DocumentSnapshot householdDoc = query.docs.first;
    Household household =
        Household.fromJson(householdDoc.data() as Map<String, dynamic>);

    await FirebaseFirestore.instance
        .collection('households')
        .doc(household.id)
        .update({
      'requested':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'requestedId': household.id,
    });

    return true;
  }

  Future<bool> cancelHouseholdRequestByCode(String code) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('households')
        .where('code', isEqualTo: code)
        .get();

    if (query.docs.isEmpty) {
      return false;
    }

    DocumentSnapshot householdDoc = query.docs.first;
    Household household =
        Household.fromJson(householdDoc.data() as Map<String, dynamic>);

    await FirebaseFirestore.instance
        .collection('households')
        .doc(household.id)
        .update({
      'requested':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });

    return true;
  }

  Future<Household?> getHousehold() async {
    final userService = GetIt.instance<UserService>();
    final userProfile = await userService.getUserProfile();
    if (userProfile.householdId != null) {
      try {
        final householdDoc = await FirebaseFirestore.instance
            .collection('households')
            .doc(userProfile.householdId)
            .get();
        if (householdDoc.exists) {
          return Household.fromJson(
              householdDoc.data() as Map<String, dynamic>);
        }
        // ignore: empty_catches
      } catch (e) {}
    }
    return null;
  }

  Future<void> leaveHousehold() async {
    final userService = GetIt.instance<UserService>();
    final userProfile = await userService.getUserProfile();
    final userId = userProfile.id;
    final householdId = userService.householdId;

    if (householdId != null) {
      await _removeUserFromHousehold(userId, householdId);
      await userService.updateUserProfile({'householdId': null});
      userService.setUserProfile({
        ...userService.userProfile!.toMap(),
        'householdId': null,
      }, userId);
    }
  }

  Future<void> _removeUserFromHousehold(
      String userId, String householdId) async {
    DocumentReference householdRef =
        FirebaseFirestore.instance.collection('households').doc(householdId);
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot householdSnapshot = await transaction.get(householdRef);
      if (householdSnapshot.exists) {
        List<dynamic> members = householdSnapshot.get('members');
        members.remove(userId);
        transaction.update(householdRef, {'members': members});
      }
      transaction.update(userRef, {'householdId': null});
    });
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        8,
        (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) %
            chars.length]).join();
  }
}
