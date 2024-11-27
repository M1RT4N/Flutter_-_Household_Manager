import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/app_state.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/models/household.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatelessWidget {
  final userService = GetIt.instance<UserService>();
  final householdService = GetIt.instance<HouseholdService>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userStream = userService.getUserStream;
    final householdStream = householdService.getHouseholdStream;
    final appStateStream = userStream.withLatestFrom<Household?, AppState>(
        householdStream, (user, household) {
      return AppState(user: user, household: household);
    });
    return LoadingStreamBuilder<AppState>(
        stream: appStateStream,
        builder: (context, appState) {
          return Row(
            children: [
              Text('username: ${appState.user?.username}'),
              Text('household name: ${appState.household?.name}'),
              Text('household code: ${appState.household?.code}')
            ],
          );

          // return PageTemplate(
          //   title: 'Home',
          //   currentRoute: '/home',
          //   user: user,
          //   household: household,
          //   // Pass current route
          //   child: Column(
          //     children: [
          //       Text('User: ${user.name}'),
          //       LoadingFutureBuilder<Household?>(
          //           future: householdService.getHousehold(),
          //           errorText: 'Could not load household info',
          //           builder: (context, household) {
          //             return Text('Household: ${household?.name ?? 'unknown'}');
          //           })
          //     ],
          //   ),
          // );
        });
  }
}
