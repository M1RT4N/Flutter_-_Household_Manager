import 'package:household_manager/models/home_page_data.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/models/todo_data.dart';

class HomePageMock {
  final TodoData todoSectionData = TodoData(
      assigner: ProfileInfo(firstName: "Zadavatel", lastName: 'Zadavac'),
      assignTime: DateTime(2024, 2, 12, 12, 12, 12),
      taskDescription:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      deadline: DateTime(2024, 3, 12));

  Future<List<TodoData>> getLatestFiveBeforeDeadline() async {
    List<TodoData> topFiveBeforeDeadline = [];
    for (int i = 0; i < 5; i += 1) {
      topFiveBeforeDeadline.add(todoSectionData);
    }
    await Future.delayed(Duration(seconds: 2));
    return topFiveBeforeDeadline;
  }

  Future<HomePageData> getHomePageData() async {
    final res = await Future.wait(
        [getLatestFiveBeforeDeadline(), getLatestFiveBeforeDeadline()]);
    return HomePageData(top5ClosestToDeadline: res[0], pastDeadline: res[1]);
  }
}
