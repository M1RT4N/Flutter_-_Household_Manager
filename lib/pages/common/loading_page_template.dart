import 'package:flutter/material.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/widgets/app_drawer.dart';

class LoadingPageTemplate<T> extends PageTemplate {
  final Stream<T> stream;
  final Widget Function(BuildContext, T) bodyFunction;
  final Widget? floatingActionButton;

  const LoadingPageTemplate({
    super.key,
    required this.stream,
    required this.bodyFunction,
    required super.title,
    super.showBackArrow,
    super.showDrawer,
    super.showLogout,
    super.showNotifications,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: showDrawer ? AppDrawer(logoutFunc: logout) : null,
      body: LoadingStreamBuilder(
        stream: stream,
        builder: (context, T model) {
          return bodyFunction(context, model);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: floatingActionButton,
    );
  }
}
