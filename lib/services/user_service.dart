import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/cupertino.dart';
import 'package:household_manager/common/database_service.dart';
import 'package:household_manager/models/user.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  final _userStream = BehaviorSubject<User?>.seeded(null);
  final DatabaseService<User> _userRepository;
  final _fbAuth = fb.FirebaseAuth.instance;

  UserService(this._userRepository);

  Stream<User?> get getUserStream => _userStream.stream;

  // CollectionReference<User> get getReference => _userRepository.reference;

  DocumentReference<User> get getUserDoc =>
      _userRepository.reference.doc(getUser?.id);

  User? get getUser => _userStream.value;

  get authChangeStream => _fbAuth.authStateChanges();

  bool get isLoggedIn => _fbAuth.currentUser != null;

  void _pushToStream(User? user) {
    _userStream.value = user;
  }

  Future<void> setUser(User user) async {
    await _updateUserInRepository(user);
    _pushToStream(user);
  }

  Future<void> _updateUserInRepository(User user) async {
    await _userRepository.setOrAdd(user.id, user);
  }

  // Future<void> leaveHousehold() async {
  //   if (_householdId != null) {
  //     String uid = _fbAuth.currentUser!.uid;
  //     await _removeUserFromHousehold(uid);
  //     _clearUserProfile();
  //   }
  // }

  Future<void> logout() async {
    await _fbAuth.signOut();
    _clearUserProfile();
  }

  void _clearUserProfile() {
    _userStream.value = null;
  }

  Future<String?> tryLogin(String usernameOrEmail, String password) async {
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
          return 'User not found';
        }

        userCredential = await _fbAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      var user = await _userRepository.getDocument(userCredential.user!.uid);
      setUser(user!);
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this username or email.';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      } else {
        return e.message ?? 'An unexpected error occurred.';
      }
    } catch (e) {
      return 'An unexpected error occurred.';
    }

    return null;
  }

  Future<String?> _getEmailByUsername(String username) async {
    var query = await _userRepository.reference
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.get('email');
    }
    return null;
  }

  Future<String?> tryRegister(
      String username, String name, String email, String password) async {
    try {
      await _fbAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await setUser(User(
          username: username,
          name: name,
          email: email,
          createdAt: Timestamp.now(),
          id: UniqueKey().toString()));
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'The email is already in use.';
      } else if (e.code == 'weak-password') {
        return 'The password is too weak.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      } else {
        return e.message ?? 'An error occurred.';
      }
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }

    return null;
  }
}
