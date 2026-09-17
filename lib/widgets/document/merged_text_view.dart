import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/state/document/scan_document.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';

/// Renders the document's entries for export inside a repaint boundary so the
/// page can capture it as an image for saving and sharing. Each entry is its
/// title heading followed by its description; [boundaryKey] is owned by the
/// page and used for that capture.
class MergedTextView extends StatelessWidget {
  /// Creates the view.
  const MergedTextView({
    super.key,
    required this.entries,
    required this.boundaryKey,
  });

  final List<DocumentEntry> entries;
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
            child: entries.isEmpty
                ? const Text(
                    '(no text)',
                    style: TextStyle(
                      fontSize: AppFontSizes.body,
                      height: AppFontSizes.bodyLineHeight,
                      color: AppColors.ink,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final DocumentEntry entry in entries) ...<Widget>[
                        Text(
                          entry.title.isEmpty ? '(no text)' : entry.title,
                          style: const TextStyle(
                            fontSize: AppFontSizes.entry,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        if (entry.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSizes.spaceS,
                            ),
                            child: Text(
                              entry.description,
                              style: const TextStyle(
                                fontSize: AppFontSizes.body,
                                height: AppFontSizes.bodyLineHeight,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSizes.spaceM),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
