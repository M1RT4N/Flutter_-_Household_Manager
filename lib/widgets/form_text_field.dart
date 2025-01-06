import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool obscureText;
  final IconData icon;
  final bool enabled;

  const FormTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
    );
  }
}
