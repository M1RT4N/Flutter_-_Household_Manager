// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: json['id'] as String,
      createdById: json['createdById'] as String,
      createdForId: json['createdForId'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Object),
      deadline: const TimestampConverter().fromJson(json['deadline'] as Object),
      description: json['description'] as String,
      title: json['title'] as String,
      householdId: json['householdId'] as String,
      completedAt: _$JsonConverterFromJson<Object, Timestamp>(
          json['completedAt'], const TimestampConverter().fromJson),
      deletedAt: _$JsonConverterFromJson<Object, Timestamp>(
          json['deletedAt'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'createdById': instance.createdById,
      'createdForId': instance.createdForId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'deadline': const TimestampConverter().toJson(instance.deadline),
      'description': instance.description,
      'completedAt': _$JsonConverterToJson<Object, Timestamp>(
          instance.completedAt, const TimestampConverter().toJson),
      'deletedAt': _$JsonConverterToJson<Object, Timestamp>(
          instance.deletedAt, const TimestampConverter().toJson),
      'title': instance.title,
      'householdId': instance.householdId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
