import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: true)
class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final String? householdId;
  final String? requestedId;
  @TimestampConverter()
  final Timestamp createdAt;
  final List<Notification> notifications;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    this.householdId,
    this.requestedId,
    required this.createdAt,
    this.notifications = const [],
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
    List<Notification>? notifications,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      householdId: householdId == null
          ? this.householdId
          : householdId == ''
              ? null
              : householdId,
      requestedId: requestedId == null
          ? this.requestedId
          : requestedId == ''
              ? null
              : requestedId,
      createdAt: createdAt ?? this.createdAt,
      notifications: notifications ?? this.notifications,
    );
  }
}

@JsonSerializable()
class Notification {
  final String id;
  final String type;
  final String title;
  final String description;
  final String link;
  final bool isHidden;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.link,
    required this.isHidden,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
}
