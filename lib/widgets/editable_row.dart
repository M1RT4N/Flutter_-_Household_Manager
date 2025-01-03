import 'package:flutter/material.dart';

class EditableRow extends StatefulWidget {
  final String leadingText;
  final String editableText;
  final TextStyle textStyle;
  final void Function(BuildContext context, String editedText) onAccept;

  const EditableRow({
    super.key,
    required this.leadingText,
    required this.editableText,
    required this.onAccept,
    required this.textStyle,
  });

  @override
  State<EditableRow> createState() => _EditableRowState();
}

class _EditableRowState extends State<EditableRow> {
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
        Text(widget.leadingText),
        isEditing
            ? Expanded(
                child: TextField(
                  controller: editingController,
                  autofocus: true,
                  style: widget.textStyle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              )
            : Text(
                widget.editableText,
                style: widget.textStyle,
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
