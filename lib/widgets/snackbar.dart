import 'package:flutter/material.dart';

const _cornerOffset = 20.0;
const _snackbarSize = 10.0;
const _snackbarInnerOffset = 2.0;
const _snackbarBlurRadius = 4.0;
const _snackbarPadding = 16.0;
const _snackbarBorderRadius = 8.0;
const _snackbarHideDuration = 3; // In seconds

class SnackBar extends StatelessWidget {
  final String message;
  final Color color;

  const SnackBar({required this.message, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _cornerOffset,
      right: _cornerOffset,
      child: Material(
        color: Colors.transparent,
        child: _buildSnackBar(),
      ),
    );
  }

  Widget _buildSnackBar() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _snackbarPadding, vertical: _snackbarPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_snackbarBorderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: _snackbarBlurRadius,
            offset: Offset(_snackbarInnerOffset, _snackbarInnerOffset),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          SizedBox(width: _snackbarSize),
          _buildMessage(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      color == Colors.red ? Icons.error : Icons.check_circle,
      color: Colors.white,
    );
  }

  Widget _buildMessage() {
    return Text(
      message,
      style: TextStyle(color: Colors.white),
    );
  }
}

void showTopSnackBar(BuildContext context, String message, Color color) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (_) => SnackBar(message: message, color: color),
  );

  Overlay.of(context).insert(overlayEntry);
  Future.delayed(Duration(seconds: _snackbarHideDuration)).then((_) {
    overlayEntry.remove();
  });
}
