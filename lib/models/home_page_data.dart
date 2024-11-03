import 'package:household_manager/models/todo_data.dart';

class HomePageData {
  final List<TodoData> top5ClosestToDeadline;
  final List<TodoData> pastDeadline;

  const HomePageData({
    required this.top5ClosestToDeadline,
    required this.pastDeadline,
  });
}
