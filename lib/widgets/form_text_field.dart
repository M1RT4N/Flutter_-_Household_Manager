import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final IconData icon;

  const FormTextField({
    Key? key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      controller: controller,
      obscureText: obscureText,
    );
  }
}
