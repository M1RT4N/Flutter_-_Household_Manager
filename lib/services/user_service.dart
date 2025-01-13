import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:household_manager/models/user.dart';
import 'package:household_manager/services/database_service.dart';
import 'package:household_manager/utils/notifications/notification_type.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  final _userStream = BehaviorSubject<User?>.seeded(null);
  final DatabaseService<User> _userRepository;
  final _fbAuth = fb.FirebaseAuth.instance;

  UserService(this._userRepository);

  Stream<User?> get getUserStream {
    final uid = _fbAuth.currentUser!.uid;
    return _userRepository.observeDocument(uid);
  }

  User? get getUser => _userStream.value;

  get authChangeStream => _fbAuth.authStateChanges();

  bool get isLoggedIn => _fbAuth.currentUser != null;

  void _pushToStream(User? user) {
    _userStream.value = user;
  }

  Future<User?> getById(String id) {
    return _userRepository.getDocument(id);
  }

  Future<User?> fetchUser(String id) async {
    final user = await getById(id);
    _pushToStream(user);
    return user;
  }

  DocumentReference<User> getUserDoc(User user) {
    return _userRepository.reference.doc(user.id);
  }

  Future<List<User>> getUsersByIds(List<String> userIds) async {
    return _userRepository.getDocumentsByIds(userIds.toSet());
  }

  Future<void> logout() async {
    await _fbAuth.signOut();
    _pushToStream(null);
  }

  Future<String?> tryLogin(String usernameOrEmail, String password) async {
    try {
      final login = Utility.isValidEmail(usernameOrEmail)
          ? usernameOrEmail
          : await _getEmailByUsername(usernameOrEmail);

      if (login == null) {
        return 'User not found.';
      }

      final userCredential = await _fbAuth.signInWithEmailAndPassword(
        email: login,
        password: password,
      );

      final user = await _userRepository.getDocument(userCredential.user!.uid);
      _pushToStream(user);
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
    final query = await _userRepository.reference
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
      final userCredential = await _fbAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        id: userCredential.user!.uid,
        username: username,
        name: name,
        email: email,
        createdAt: Timestamp.now(),
      );

      await setUser(user);
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

  Future<void> updateUser(User newUser) async {
    _userRepository.setOrAdd(newUser.id, newUser);
  }

  Future<void> setUser(User newUser) async {
    await updateUser(newUser);
    _pushToStream(newUser);
  }

  Future<void> addNotification(String userId, NotificationType type,
      String title, String description, String? link) async {
    final user = await getById(userId);
    if (user == null) return;

    // We would do keys based on time to ensure uniqueness in single user
    // if two different users have same notification ID we would not care
    final now = DateTime.now();

    final newNotification = Notification(
      id: now.microsecondsSinceEpoch.toString(),
      type: type,
      title: title,
      description: description,
      link: link,
      isHidden: false, // By default, notifications are not hidden
    );

    final updatedNotifications = List<Notification>.from(user.notifications)
      ..add(newNotification);

    final updatedUser = user.copyWith(notifications: updatedNotifications);
    await updateUser(updatedUser);
  }

  Future<void> hideNotification(String notificationId) async {
    final user = getUser;
    if (user == null) return;

    final updatedNotifications = user.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isHidden: true);
      }
      return notification;
    }).toList();

    final updatedUser = user.copyWith(notifications: updatedNotifications);
    await setUser(updatedUser);
  }

  Future<String?> updateUserProfile(
      String username, String name, String? avatarUrl) async {
    try {
      final user = getUser;
      if (user == null) {
        return 'User not found.';
      }

      final updatedUser = user.copyWith(
        username: username,
        name: name,
        avatarUrl: avatarUrl ?? user.avatarUrl,
      );
      await setUser(updatedUser);
      _pushToStream(updatedUser);
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }

    return null;
  }

  Future<String?> changeName(String newName) async {
    setUser(getUser!.copyWith(name: newName));
    return null;
  }

  Future<String?> changeUsername(String newUsername) async {
    setUser(getUser!.copyWith(username: newUsername));
    return null;
  }

  Future<String?> changeEmail(String newEmail) async {
    setUser(getUser!.copyWith(email: newEmail));
    return null;
  }
}
