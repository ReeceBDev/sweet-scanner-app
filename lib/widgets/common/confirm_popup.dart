import 'package:flutter/material.dart';

/// Wireframe yes/no confirmation popup widget. The caller decides what the
/// answer does.
class ConfirmPopup extends StatelessWidget {
  /// Creates the popup.
  const ConfirmPopup({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Yes',
    this.cancelLabel = 'No',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Shows the popup and hands back whether it was confirmed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Yes',
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ConfirmPopup(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
