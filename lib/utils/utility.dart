import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/widgets/snack_bar.dart';
import 'package:json_annotation/json_annotation.dart';

class Utility {
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static String generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  static String getUserInitials(String? name) {
    if (name == null) {
      return '';
    }

    return name.trim().split(' ').map((e) => e[0]).take(2).join();
  }

  static Future<bool?> showConfirmationDialog(
      BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  static Future<void> handleActionWithConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required Future<void> Function() action,
    String successMessage = '',
    String? errorMessage,
    String? navigateTo,
  }) async {
    final confirm = await Utility.showConfirmationDialog(
      context,
      title,
      message,
    );

    if (confirm == true) {
      try {
        await action();

        if (context.mounted) {
          if (successMessage.isNotEmpty) {
            showTopSnackBar(context, successMessage, Colors.green);
          }
          if (navigateTo != null) {
            Modular.to.navigate(navigateTo);
          }
        }
      } catch (e) {
        if (context.mounted && errorMessage != null) {
          showTopSnackBar(context, '$errorMessage: $e', Colors.red);
        }
      }
    }
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
