import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/state/document/scan_document.dart';
import 'package:sweet_scanner_app/theme/sizes.dart';
import 'package:sweet_scanner_app/widgets/document/document_entry_tile.dart';

/// The text list: the expand/collapse list of a document's entries with a
/// trash action on each. Pure presentation; deletion confirmation is the
/// caller's decision.
class TextList extends StatelessWidget {
  /// Creates the list.
  const TextList({
    super.key,
    required this.entries,
    required this.onEntryDelete,
  });

  final List<DocumentEntry> entries;
  final void Function(DocumentEntry entry) onEntryDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No entries'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spaceM),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        final DocumentEntry entry = entries[index];
        return DocumentEntryTile(
          entry: entry,
          onDelete: () => onEntryDelete(entry),
        );
      },
    );
  }
}
