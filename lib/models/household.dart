import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:household_manager/utils/utility.dart';
import 'package:json_annotation/json_annotation.dart';

part 'household.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Household {
  final String id;
  final String name;
  final String code;
  final List<String> members;
  final List<String> requested;

  @TimestampConverter()
  final Timestamp createdAt;

  Household({
    required this.id,
    required this.name,
    required this.code,
    required this.members,
    required this.requested,
    required this.createdAt,
  });

  factory Household.fromJson(Map<String, dynamic> json) =>
      _$HouseholdFromJson(json);
  Map<String, dynamic> toJson() => _$HouseholdToJson(this);
}
