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
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'name': instance.name,
      if (instance.householdId != null) 'householdId': instance.householdId,
      if (instance.requestedId != null) 'requestedId': instance.requestedId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
