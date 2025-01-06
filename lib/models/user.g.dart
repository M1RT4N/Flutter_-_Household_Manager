// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      householdId: json['householdId'] as String?,
      requestedId: json['requestedId'] as String?,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Object),
      notifications: (json['notifications'] as List<dynamic>?)
              ?.map((e) => Notification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'name': instance.name,
      'householdId': instance.householdId,
      'requestedId': instance.requestedId,
      'avatarUrl': instance.avatarUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'notifications': instance.notifications.map((e) => e.toJson()).toList(),
    };

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      link: json['link'] as String?,
      isHidden: json['isHidden'] as bool,
    );

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'link': instance.link,
      'isHidden': instance.isHidden,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.userJoined: 'userJoined',
  NotificationType.userRejected: 'userRejected',
  NotificationType.userLeft: 'userLeft',
  NotificationType.todoAssigned: 'todoAssigned',
  NotificationType.todoCompleted: 'todoCompleted',
};
