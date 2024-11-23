import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class User {
  final String id;
  final String username;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
