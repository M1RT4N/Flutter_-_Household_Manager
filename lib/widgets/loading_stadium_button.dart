import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';

const _buttonWidth = 120.0;
const _buttonHeight = 40.0;
const _loadingCircleStrokeWidth = 2.0;
const _buttonRadius = 20.0;
const _buttonElevation = 2.0;

class LoadingStadiumButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const LoadingStadiumButton(
      {super.key, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return EasyButton(
      type: EasyButtonType.elevated,
      elevation: _buttonElevation,
      width: _buttonWidth,
      height: _buttonHeight,
      buttonColor: Theme.of(context).primaryColor,
      borderRadius: _buttonRadius,
      idleStateWidget: Text(buttonText),
      onPressed: onPressed,
      useWidthAnimation: false,
      loadingStateWidget: CircularProgressIndicator(
        strokeWidth: _loadingCircleStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).secondaryHeaderColor),
      ),
    );
  }
}
