import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/utils/utility.dart';

class ProfileInfo {
  final String id;
  final String username;
  final String name;
  final String email;
  String? householdId;

  @TimestampConverter()
  final Timestamp createdAt;

  ProfileInfo({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    this.householdId,
    required this.createdAt,
  });

  factory ProfileInfo.fromMap(Map<String, dynamic> map, String id) {
    return ProfileInfo(
      id: id,
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      householdId: map['householdId'],
      createdAt:
          TimestampConverter().fromJson(map['createdAt'] ?? Timestamp.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'householdId': householdId,
      'createdAt': TimestampConverter().toJson(createdAt),
    };
  }
}
