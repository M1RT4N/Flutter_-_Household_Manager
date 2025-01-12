import 'package:flutter/material.dart';
import 'package:household_manager/common/loading_builder.dart';
import 'package:household_manager/pages/common/page_template.dart';
import 'package:household_manager/widgets/app_drawer.dart';

const _maxPhoneWidth = 500.0;

class LoadingPageTemplate<T> extends PageTemplate {
  final Stream<T> stream;
  final Widget Function(BuildContext, T) bodyFunctionPhone;
  final Widget Function(BuildContext, T) bodyFunctionWeb;
  final Widget? floatingActionButton;

  const LoadingPageTemplate(
      {super.key,
      required super.title,
      required this.stream,
      required this.bodyFunctionPhone,
      required this.bodyFunctionWeb,
      super.showBackArrow,
      super.showDrawer,
      super.showLogout,
      super.showNotifications,
      this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < _maxPhoneWidth;

    return Scaffold(
      appBar: buildAppBar(context),
      drawer: showDrawer ? AppDrawer(logoutFunc: logout) : null,
      body: LoadingStreamBuilder(
        stream: stream,
        builder: (context, T model) {
          return isPhone
              ? bodyFunctionPhone(context, model)
              : bodyFunctionWeb(context, model);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: floatingActionButton,
    );
  }
}
