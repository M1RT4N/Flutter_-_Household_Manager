import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:household_manager/widgets/snack_bar.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

const _dateFormat = 'dd.MM.yyyy';
const _maxEpochDate = 8640000000000000;

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

  static String getUserInitials(String name) {
    return name.split(" ").map((x) => x[0]).join();
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

  static void pickDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.fromMicrosecondsSinceEpoch(_maxEpochDate));

    if (pickedDate != null) {
      controller.text = formatDate(pickedDate);
    } else {
      controller.clear();
    }
  }

  static Future<void> handleActionWithConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required Future<String?> Function() action,
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
        if (context.mounted) {
          await performActionAndShowInfo(
              context: context, action: action, successMessage: successMessage);
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

  static String getStringFromEnum(Enum enumValue) {
    return enumValue.toString().split('.')[1];
  }

  static Future<void> performActionAndShowInfo({
    required BuildContext context,
    required Future<String?> Function() action,
    required String successMessage,
    Color successColor = Colors.blue,
  }) async {
    final error = await action();
    if (context.mounted) {
      showTopSnackBar(
        context,
        error ?? successMessage,
        error == null ? successColor : Colors.red,
      );
    }
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat(_dateFormat).format(dateTime);
  }

  static DateTime parseDate(String data) {
    return DateFormat(_dateFormat).parse(data);
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
