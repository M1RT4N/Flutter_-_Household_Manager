import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:household_manager/models/household.dart';

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

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
        8,
        (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) %
            chars.length]).join();
  }
}
