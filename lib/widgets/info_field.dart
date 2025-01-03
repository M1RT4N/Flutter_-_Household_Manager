import 'package:flutter/material.dart';

const _labelTextStyle = TextStyle(fontSize: 16, color: Colors.grey);
const _mainTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
const _labelTextGap = SizedBox(width: 8);
const _padding = EdgeInsets.symmetric(vertical: 8.0);

class InfoField extends StatelessWidget {
  final String labelText;
  final String mainText;
  final Widget? trailingWidget;

  const InfoField({
    super.key,
    required this.labelText,
    required this.mainText,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$labelText:', style: _labelTextStyle),
          _labelTextGap,
          Text(mainText, style: _mainTextStyle),
          if (trailingWidget != null) trailingWidget!
        ],
      ),
    );
  }
}
