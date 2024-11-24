import 'package:flutter/material.dart';

class StadiumButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const StadiumButton(
      {Key? key,
      required this.text,
      required this.width,
      required this.height,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        shape: StadiumBorder(),
      ),
      child: Text(text),
    );
  }
}
