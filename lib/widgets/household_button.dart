import 'package:flutter/material.dart';

const _boxSize = 250.0;
const _mainIconSize = 40.0;
const _mainButtonBorderRadius = 8.0;
const _mainButtonPadding = 16.0;
const _mainButtonFontSize = 16.0;

class HouseholdButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const HouseholdButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _boxSize,
      height: _boxSize,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(_mainButtonPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_mainButtonBorderRadius),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _mainIconSize),
            const SizedBox(height: _mainButtonPadding / 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: _mainButtonFontSize),
            ),
          ],
        ),
      ),
    );
  }
}
