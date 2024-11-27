import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:household_manager/common/page_template.dart';
import 'package:household_manager/services/household_service.dart';
import 'package:household_manager/services/user_service.dart';
import 'package:household_manager/widgets/loading_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String householdName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
        title: 'Home',
        currentRoute: '/home', // Pass current route
        child: Scaffold(
          body: isLoading
              ? LoadingScreen()
              : Column(
                  children: [
                    Text('User: $userName'),
                    Text('Household: $householdName'),
                  ],
                ),
        ));
  }

  Future<void> _fetchData() async {
    final userService = GetIt.instance<UserService>();
    final householdService = GetIt.instance<HouseholdService>();

    final user = await userService.getUserProfile();
    final household = await householdService.getHousehold();

    setState(() {
      userName = user.name;
      householdName = household?.name ?? 'Unknown Household';
      isLoading = false;
    });
  }
}
