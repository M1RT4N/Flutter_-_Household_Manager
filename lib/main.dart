import 'package:flutter/material.dart';
import 'package:household_manager/app_wrapper.dart';
import 'package:household_manager/utils/firebase/main.dart';
import 'package:household_manager/utils/ioc_container.dart';

void main() async {
  await FirebasePlatform.setup();
  IocContainer.setup();

  runApp(HouseholdManagerApp());
}
