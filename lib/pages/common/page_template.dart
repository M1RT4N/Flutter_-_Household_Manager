import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;

  const PageTemplate({super.key, required this.appBar, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
    );
  }
}
