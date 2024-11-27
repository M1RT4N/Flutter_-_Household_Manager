import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:household_manager/common/database_service.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  final _userStream = BehaviorSubject<User?>.seeded(null);
  final DatabaseService<User> _userRepository;
  final fb.FirebaseAuth _fbAuth = fb.FirebaseAuth.instance;
  String? errorMessage;

  UserService(this._userRepository);

  Stream<User?> get getUserStream => _userStream.stream;

  get authChangeStream => _fbAuth.authStateChanges();

  String? get getError => errorMessage;

  bool get isLoggedIn => _fbAuth.currentUser != null;

  void _pushToStream(User? newUser) {
    _userStream.value = newUser;
  }

  void setUser(User user) {
    _pushToStream(user);
    _updateUserProfileInFireStore(user);
  }

  Future<void> _updateUserProfileInFireStore(User user) async {
    await _userRepository.setOrAdd(user.id, user);
  }

  Future<bool> fetchUser() async {
    return
  }

  //
  // Future<Map<String, dynamic>> fetchUserProfileWithHousehold() async {
  //   final user = _fbAuth.currentUser;
  //   if (user != null) {
  //     User? user = await getUserProfile();
  //     await fetchUserProfile();
  //     return await _fetchHouseholdData(user);
  //   }
  //   return {};
  // }

  // Future<Map<String, dynamic>> _fetchHouseholdData(User user) async {
  //   DocumentSnapshot householdDoc = await FirebaseFirestore.instance
  //       .collection('households')
  //       .doc(user.householdId)
  //       .get();
  //   Household? household;
  //   if (householdDoc.exists) {
  //     household =
  //         Household.fromJson(householdDoc.data() as Map<String, dynamic>);
  //   }
  //   return {'userInfo': user, 'household': household};
  // }

  // Future<void> leaveHousehold() async {
  //   if (_householdId != null) {
  //     String uid = _fbAuth.currentUser!.uid;
  //     await _removeUserFromHousehold(uid);
  //     _clearUserProfile();
  //   }
  // }
  //
  // Future<void> _removeUserFromHousehold(String uid) async {
  //   if (_householdId == null) return;
  //
  //   DocumentReference householdRef =
  //       FirebaseFirestore.instance.collection('households').doc(_householdId);
  //   DocumentReference userRef =
  //       FirebaseFirestore.instance.collection('users').doc(uid);
  //
  //   await FirebaseFirestore.instance.runTransaction((transaction) async {
  //     DocumentSnapshot householdSnapshot = await transaction.get(householdRef);
  //     if (householdSnapshot.exists) {
  //       List<dynamic> members = householdSnapshot.get('members');
  //       members.remove(uid);
  //       transaction.update(householdRef, {'members': members});
  //     }
  //     transaction.update(userRef, {'householdId': null});
  //   });
  // }
  //
  // Future<void> updateUserProfile(Map<String, dynamic> data) async {
  //   await fetchUserProfile();
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userStream!.id)
  //         .update(data);
  //   } catch (e) {
  //     throw Exception('Failed to update user user: ${e.toString()}');
  //   }
  // }
  //
  Future<void> logout() async {
    await _fbAuth.signOut();
    _clearUserProfile();
  }

  void _clearUserProfile() {
    _userStream.value = null;
  }

  //
  // Future<User> getUserProfile() async {
  //   if (userStream == null) {
  //     await fetchUserProfile();
  //   }
  //
  //   if (userStream == null) {
  //     throw Exception('User user not found.');
  //   }
  //   return userStream!;
  // }

  Future<User?> tryLogin(String usernameOrEmail, String password) async {
    try {
      fb.UserCredential userCredential;
      if (Utility.isValidEmail(usernameOrEmail)) {
        userCredential = await _fbAuth.signInWithEmailAndPassword(
          email: usernameOrEmail,
          password: password,
        );
      } else {
        String? email = await _getEmailByUsername(usernameOrEmail);
        if (email == null) {
          errorMessage = 'User not found';
          return null;
        }
        userCredential = await _fbAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      var userDoc = await userCollection.doc(userCredential.user?.uid).get();

      if (userDoc.exists) {
        var x = userDoc.id;
        var user = User.fromJson(userDoc.data()!);
        setUser(user..copyWith(id: userCredential.user!.uid));
        return user;
      }
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this username or email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is badly formatted.';
      } else {
        errorMessage = e.message ?? 'An unexpected error occurred.';
      }
    } catch (e) {
      errorMessage = 'An unexpected error occurred.';
    }

    return null;
  }

  Future<String?> _getEmailByUsername(String username) async {
    var query = await userCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.get('email');
    }
    return null;
  }
}
