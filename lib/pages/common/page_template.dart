import 'package:flutter/material.dart';

class PageTemplate extends StatelessWidget {
  final String _title;
  final Widget _child;

  const PageTemplate({super.key, required String title, required Widget child})
      : _child = child,
        _title = title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: _child,
    );
  }
}
