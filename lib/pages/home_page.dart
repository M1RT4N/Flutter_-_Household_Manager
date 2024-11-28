import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';

class HomePage extends StatelessWidget {
  final userService = GetIt.instance<UserService>();
  final householdService = GetIt.instance<HouseholdService>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'Home',
        child: Scaffold(
          body: Column(
            children: [
              Text('User: ${userService.getUser?.username}'),
              Text('Household name: ${householdService.getHousehold?.name}'),
              Text('Household code: ${householdService.getHousehold?.code}'),
            ],
          ),
        ));
  }
}
