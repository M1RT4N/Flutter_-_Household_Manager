import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:json_annotation/json_annotation.dart';

class Utility {
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}

class TimestampConverter implements JsonConverter<Timestamp, Object> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Object json) {
    if (json is Timestamp) {
      return json;
    }
    if (json is int) {
      return Timestamp.fromMicrosecondsSinceEpoch(json);
    }
    throw ArgumentError('Invalid type for Timestamp conversion.');
  }

  @override
  Object toJson(Timestamp object) => object;
}

Future<void> checkAuth() async {
  if (FirebaseAuth.instance.currentUser != null) {
    Modular.to.navigate('/home');
    return;
  }
  Modular.to.navigate('/login');
}

void logout(BuildContext context, UserService userService) async {
  await userService.logout();
  if (context.mounted) {
    Modular.to.navigate('/login');
  }
}
