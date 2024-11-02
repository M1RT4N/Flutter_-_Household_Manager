import 'package:flutter/material.dart';
import 'package:household_manager/pages/login_page.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      theme: ThemeData(primarySwatch: Colors.yellow, useMaterial3: false),
    );
  }
}
