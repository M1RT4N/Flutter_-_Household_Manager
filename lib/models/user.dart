import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final String? householdId;
  final String? requestedId;

  @TimestampConverter()
  final Timestamp createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    this.householdId,
    this.requestedId,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? householdId,
    String? requestedId,
    Timestamp? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      householdId: householdId ?? this.householdId,
      requestedId: requestedId ?? this.requestedId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
