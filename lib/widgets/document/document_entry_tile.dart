import 'dart:io';

import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/state/document/scan_document.dart';
import 'package:sweet_scanner_app/theme/colors.dart';
import 'package:sweet_scanner_app/theme/font_sizes.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/scanner_icon_button.dart';

/// One row in the text list: thumbnail on the left, the recognised text
/// beside it (tapping expands/collapses it), and the trash icon on the right.
/// Deletion confirmation is the caller's decision.
class DocumentEntryTile extends StatefulWidget {
  /// Creates the tile.
  const DocumentEntryTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  final DocumentEntry entry;
  final VoidCallback onDelete;

  @override
  State<DocumentEntryTile> createState() => _DocumentEntryTileState();
}

class _DocumentEntryTileState extends State<DocumentEntryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.ink, width: AppSizes.borderWidth),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () => setState(() {
              _expanded = !_expanded;
            }),
            child: SizedBox(
              width: AppSizes.entryThumbWidth,
              height: AppSizes.thumbnailHeight,
              child: Image.file(
                File(widget.entry.photoPath),
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return const ColoredBox(color: AppColors.disabled);
                    },
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _expanded = !_expanded;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceM,
                  vertical: AppSizes.spaceS,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.entry.title.isEmpty
                          ? '(no text)'
                          : widget.entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppFontSizes.entry,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.entry.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.spaceS),
                        child: Text(
                          widget.entry.description,
                          maxLines: _expanded ? null : 1,
                          overflow: _expanded ? null : TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: AppFontSizes.body),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.spaceS),
            child: ScannerIconButton(
              icon: Icons.delete,
              tooltip: 'Delete',
              onPressed: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
