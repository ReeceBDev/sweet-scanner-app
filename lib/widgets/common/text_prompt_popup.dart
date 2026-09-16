import 'package:flutter/material.dart';

/// Modal popup with a text field; the on-screen keyboard appears with it.
/// Used for naming and renaming.
class TextPromptPopup extends StatefulWidget {
  /// Creates the popup; [initialText] prefills the field (renaming).
  const TextPromptPopup({
    super.key,
    required this.title,
    this.initialText = '',
    this.hintText = 'Name',
    this.confirmLabel = 'Done',
  });

  final String title;
  final String initialText;
  final String hintText;
  final String confirmLabel;

  /// Shows the popup and hands back the trimmed entry, or null when the user
  /// cancelled.
  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    String initialText = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => TextPromptPopup(
        title: title,
        initialText: initialText,
      ),
    );
  }

  @override
  State<TextPromptPopup> createState() => _TextPromptPopupState();
}

class _TextPromptPopupState extends State<TextPromptPopup> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String value = _controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (String value) => _submit(),
        decoration: InputDecoration(hintText: widget.hintText),
      ),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
