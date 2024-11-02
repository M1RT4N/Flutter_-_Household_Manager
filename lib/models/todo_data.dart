import 'package:household_manager/models/profile_info.dart';

class TodoData {
  final ProfileInfo assigner;
  final DateTime assignTime;
  final String taskDescription;
  final DateTime deadline;

  const TodoData({
    required this.assigner,
    required this.assignTime,
    required this.taskDescription,
    required this.deadline,
  });
}
