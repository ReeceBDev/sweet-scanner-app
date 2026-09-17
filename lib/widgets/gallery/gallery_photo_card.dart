import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/state/capture/captured_photo.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/common/expandable_text_box.dart';
import 'package:sweet_scanner_app/widgets/scanner_icon_button.dart';

/// One photo in a gallery: a thumbnail that expands on tap; while expanded it
/// carries the trash / retake icons and the OCR text box underneath.
class GalleryPhotoCard extends StatefulWidget {
  /// Creates the card. [onDelete] / [onRetake] may be null to hide the
  /// corresponding icons.
  const GalleryPhotoCard({
    super.key,
    required this.photo,
    required this.onOcrRetry,
    this.onDelete,
    this.onRetake,
  });

  final CapturedPhoto photo;
  final VoidCallback onOcrRetry;
  final VoidCallback? onDelete;
  final VoidCallback? onRetake;

  @override
  State<GalleryPhotoCard> createState() => _GalleryPhotoCardState();
}

class _GalleryPhotoCardState extends State<GalleryPhotoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final CapturedPhoto photo = widget.photo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () => setState(() {
            _expanded = !_expanded;
          }),
          child: SizedBox(
            width: double.infinity,
            height: _expanded
                ? AppSizes.expandedPhotoHeight
                : AppSizes.thumbnailHeight,
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return const ColoredBox(color: AppColors.disabled);
                  },
            ),
          ),
        ),
        if (_expanded) ...<Widget>[
          const SizedBox(height: AppSizes.spaceS),
          Row(
            children: <Widget>[
              if (widget.onDelete != null)
                ScannerIconButton(
                  icon: Icons.delete,
                  tooltip: 'Delete',
                  onPressed: widget.onDelete,
                ),
              if (widget.onRetake != null) ...<Widget>[
                const SizedBox(width: AppSizes.spaceS),
                ScannerIconButton(
                  icon: Icons.refresh,
                  tooltip: 'Retake',
                  onPressed: widget.onRetake,
                ),
              ],
            ],
          ),
          ExpandableTextBox(
            text: photo.text,
            status: photo.status,
            onRetry: widget.onOcrRetry,
          ),
        ],
        const SizedBox(height: AppSizes.spaceM),
      ],
    );
  }
}
