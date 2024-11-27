import 'package:flutter/material.dart';
import 'package:household_manager/widgets/loading_screen.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() actionCallback;

  const SplashScreen({super.key, required this.actionCallback});

  @override
  createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    widget.actionCallback();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen();
  }
}
