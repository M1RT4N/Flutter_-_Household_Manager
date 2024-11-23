import 'package:flutter/material.dart';
import 'package:household_manager/models/profile_info.dart';
import 'package:household_manager/widgets/login_template.dart';

class HomePage extends StatefulWidget {
  final ProfileInfo profileInfo;

  const HomePage({super.key, required this.profileInfo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginTemplate(
        title: 'Home',
        breadcrumbPath: const ['Home'],
        currentRoute: '/home', // Pass current route
        child: Scaffold(
          body: Text('Home Page'),
        ));
  }
}
