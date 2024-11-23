import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:household_manager/utils/firebase/options.dart';

class FirebasePlatform {
  static Future<void> setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
