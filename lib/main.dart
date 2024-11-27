import 'package:flutter/material.dart';
import 'package:household_manager/household_manager_app.dart';
import 'package:household_manager/utils/firebase/main.dart';
import 'package:household_manager/utils/ioc_container.dart';

void main() async {
  await FirebasePlatform.setup();
  IocContainer.setup();

  runApp(HouseholdManagerApp());
}
