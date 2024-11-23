import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/models/profile_info.dart';

class UserService {
  ProfileInfo? _userProfile;

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  ProfileInfo? get userProfile => _userProfile;

  Future<void> setUserProfile(Map<String, dynamic>? profile) async {
    if (profile != null) {
      _userProfile = ProfileInfo.fromMap(profile);
    }
  }

  Future<void> fetchUserProfile() async {
    if (isLoggedIn) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setUserProfile(userDoc.data() as Map<String, dynamic>?);
    } else {
      _userProfile = null;
    }
  }

  ProfileInfo getUserProfile() {
    if (_userProfile == null) {
      throw Exception('User profile not found.');
    }
    return _userProfile!;
  }
}
