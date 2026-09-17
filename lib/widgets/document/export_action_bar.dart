import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/scanner_icon_button.dart';

/// Bottom action bar of the export view: copy to clipboard, save the text as
/// an image file, share the text as an image file.
class ExportActionBar extends StatelessWidget {
  /// Creates the bar; all three actions are required.
  const ExportActionBar({
    super.key,
    required this.onCopy,
    required this.onSave,
    required this.onShare,
  });

  final VoidCallback onCopy;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.ink, width: AppSizes.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.spaceS,
            horizontal: AppSizes.spaceL,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ScannerIconButton(
                icon: Icons.copy,
                tooltip: 'Copy',
                onPressed: onCopy,
              ),
              ScannerIconButton(
                icon: Icons.save,
                tooltip: 'Save as image',
                onPressed: onSave,
              ),
              ScannerIconButton(
                icon: Icons.share,
                tooltip: 'Share as image',
                onPressed: onShare,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
