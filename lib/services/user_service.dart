import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/profile_info.dart';

class UserService {
  ProfileInfo? _userProfile;
  String? _householdId;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  ProfileInfo? get userProfile => _userProfile;
  String? get householdId => _householdId;

  Future<void> setUserProfile(Map<String, dynamic>? profile, String uid) async {
    if (profile != null) {
      _userProfile = ProfileInfo.fromMap(profile, uid);
      _householdId = _userProfile?.householdId;
    }
  }

  Future<void> fetchUserProfile() async {
    if (isLoggedIn) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      await setUserProfile(userDoc.data() as Map<String, dynamic>?, uid);
    } else {
      _clearUserProfile();
    }
  }

  Future<void> leaveHousehold() async {
    if (_householdId != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference householdRef =
          FirebaseFirestore.instance.collection('households').doc(_householdId);
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot householdSnapshot =
            await transaction.get(householdRef);
        if (householdSnapshot.exists) {
          List<dynamic> members = householdSnapshot.get('members');
          members.remove(uid);
          transaction.update(householdRef, {'members': members});
        }
        transaction.update(userRef, {'householdId': null});
      });

      _clearUserProfile();
    }
  }

  void _clearUserProfile() {
    _userProfile = null;
    _householdId = null;
  }

  ProfileInfo getUserProfile() {
    if (_userProfile == null) {
      throw Exception('User profile not found.');
    }
    return _userProfile!;
  }
}
