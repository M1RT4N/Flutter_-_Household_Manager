import 'package:flutter/material.dart';

const _labelTextStyle = TextStyle(fontSize: 16, color: Colors.grey);
const _editableTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
const _labelTextGap = SizedBox(width: 8);

class EditableField extends StatefulWidget {
  final String labelText;
  final String editableText;
  final void Function(BuildContext context, String editedText) onAccept;

  const EditableField({
    super.key,
    required this.labelText,
    required this.editableText,
    required this.onAccept,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  bool isEditing = false;
  late TextEditingController editingController;

  @override
  void initState() {
    super.initState();
    editingController = TextEditingController(text: widget.editableText);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.labelText, style: _labelTextStyle),
        _labelTextGap,
        isEditing
            ? Expanded(
                child: TextField(
                  controller: editingController,
                  autofocus: true,
                  style: _editableTextStyle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              )
            : Text(
                widget.editableText,
                style: _editableTextStyle,
              ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          onPressed: () {
            if (isEditing) {
              widget.onAccept(context, editingController.text);
              setState(() {
                isEditing = false;
              });
            } else {
              setState(() {
                isEditing = true;
              });
            }
          },
        ),
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                isEditing = false;
                editingController.text = widget.editableText;
              });
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }
}
