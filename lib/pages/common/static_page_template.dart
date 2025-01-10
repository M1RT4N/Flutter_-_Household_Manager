import 'package:flutter/material.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/widgets/app_drawer.dart';

class StaticPageTemplate extends PageTemplate {
  final Widget Function(BuildContext) bodyFunction;

  const StaticPageTemplate(
      {super.key,
      required super.title,
      required this.bodyFunction,
      super.showBackArrow,
      super.showDrawer,
      super.showLogout,
      super.showNotifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: showDrawer ? AppDrawer(logoutFunc: logout) : null,
      body: bodyFunction(context),
    );
  }
}
