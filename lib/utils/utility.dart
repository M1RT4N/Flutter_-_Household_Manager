import 'package:cloud_firestore/cloud_firestore.dart';
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
