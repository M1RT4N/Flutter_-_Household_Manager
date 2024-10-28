import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {

  final String title;
  final Widget child;

  const PageTemplate({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: child,
    );
  }
}
