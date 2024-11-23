import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/profile_info.dart';

class UserService {
  ProfileInfo? userProfile;
  String? _householdId;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  String? get householdId => _householdId;

  Future<void> setUserProfile(Map<String, dynamic>? profile, String uid) async {
    if (profile != null) {
      userProfile = ProfileInfo.fromMap(profile, uid);
      _householdId = userProfile?.householdId;
    }
  }

  Future<void> setUserProfileFromInfo(ProfileInfo profile, String uid) async {
    await _updateUserProfileInFirestore(profile, uid);
  }

  Future<void> _updateUserProfileInFirestore(
      ProfileInfo profile, String uid) async {
    userProfile = profile;
    _householdId = profile.householdId;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(profile.toMap());
  }

  Future<ProfileInfo?> fetchUserProfile() async {
    if (isLoggedIn) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await _fetchAndSetUserProfile(uid);
      return userProfile;
    } else {
      _clearUserProfile();
      return null;
    }
  }

  Future<void> _fetchAndSetUserProfile(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    await setUserProfile(userDoc.data() as Map<String, dynamic>?, uid);
  }

  Future<Map<String, dynamic>> fetchUserProfileWithHousehold() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ProfileInfo? profile = await getUserProfile();
      await fetchUserProfile();
      return await _fetchHouseholdData(profile);
    }
    return {};
  }

  Future<Map<String, dynamic>> _fetchHouseholdData(ProfileInfo profile) async {
    DocumentSnapshot householdDoc = await FirebaseFirestore.instance
        .collection('households')
        .doc(profile.householdId)
        .get();
    Household? household;
    if (householdDoc.exists) {
      household =
          Household.fromJson(householdDoc.data() as Map<String, dynamic>);
    }
    return {'profileInfo': profile, 'household': household};
  }

  Future<void> leaveHousehold() async {
    if (_householdId != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await _removeUserFromHousehold(uid);
      _clearUserProfile();
    }
  }

  Future<void> _removeUserFromHousehold(String uid) async {
    if (_householdId == null) return;

    DocumentReference householdRef =
        FirebaseFirestore.instance.collection('households').doc(_householdId);
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot householdSnapshot = await transaction.get(householdRef);
      if (householdSnapshot.exists) {
        List<dynamic> members = householdSnapshot.get('members');
        members.remove(uid);
        transaction.update(householdRef, {'members': members});
      }
      transaction.update(userRef, {'householdId': null});
    });
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await fetchUserProfile();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userProfile!.id)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _clearUserProfile();
  }

  void _clearUserProfile() {
    userProfile = null;
    _householdId = null;
  }

  Future<ProfileInfo> getUserProfile() async {
    if (userProfile == null) {
      await fetchUserProfile();
    }

    if (userProfile == null) {
      throw Exception('User profile not found.');
    }
    return userProfile!;
  }
}
