// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Household _$HouseholdFromJson(Map<String, dynamic> json) => Household(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
      requested:
          (json['requested'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Object),
    );

Map<String, dynamic> _$HouseholdToJson(Household instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'members': instance.members,
      'requested': instance.requested,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
