import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';

/// Renders the merged block of text inside a repaint boundary so the page can
/// capture it as an image for saving and sharing. [boundaryKey] is owned by
/// the page and used for that capture.
class MergedTextView extends StatelessWidget {
  /// Creates the view.
  const MergedTextView({
    super.key,
    required this.text,
    required this.boundaryKey,
  });

  final String text;
  final GlobalKey boundaryKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceM),
        child: RepaintBoundary(
          key: boundaryKey,
          child: Container(
            width: double.infinity,
            color: AppColors.background,
            padding: const EdgeInsets.all(AppSizes.spaceL),
            child: Text(
              text.isEmpty ? '(no text)' : text,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                height: AppFontSizes.bodyLineHeight,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
