import 'package:flutter/material.dart';

const _cornerOffset = 20.0;
const _snackBarSize = 10.0;
const _snackBarInnerOffset = 2.0;
const _snackBarBlurRadius = 4.0;
const _snackBarPadding = 16.0;
const _snackBarBorderRadius = 8.0;
const _snackBarHideDuration = 3; // In seconds

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
          horizontal: _snackBarPadding, vertical: _snackBarPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_snackBarBorderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: _snackBarBlurRadius,
            offset: Offset(_snackBarInnerOffset, _snackBarInnerOffset),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          SizedBox(width: _snackBarSize),
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
  Future.delayed(Duration(seconds: _snackBarHideDuration)).then((_) {
    overlayEntry.remove();
  });
}
