import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: true)
class Todo {
  final String id;
  final String createdById;
  final String createdForId;
  @TimestampConverter()
  final Timestamp createdAt;
  @TimestampConverter()
  final Timestamp deadline;
  final String description;
  @TimestampConverter()
  final Timestamp? completedAt;
  @TimestampConverter()
  final Timestamp? deletedAt;
  final String title;
  final String householdId;

  Todo({
    required this.id,
    required this.createdById,
    required this.createdForId,
    required this.createdAt,
    required this.deadline,
    required this.description,
    required this.title,
    required this.householdId,
    this.completedAt,
    this.deletedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);

  Todo copyWith({
    String? id,
    String? createdById,
    String? createdForId,
    Timestamp? createdAt,
    Timestamp? deadline,
    String? description,
    Timestamp? completedAt,
    Timestamp? deletedAt,
    String? title,
    String? householdId,
  }) {
    return Todo(
      id: id ?? this.id,
      createdById: createdById ?? this.createdById,
      createdForId: createdForId ?? this.createdForId,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      title: title ?? this.title,
      householdId: householdId ?? this.householdId,
    );
  }
}
