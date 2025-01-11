import 'package:household_manager/models/household.dart';
import 'package:household_manager/models/user.dart';

class HouseholdDto {
  final Household household;
  final List<User> members;
  final List<User> requesters;

  HouseholdDto({
    required this.household,
    required this.members,
    required this.requesters,
  });
}
