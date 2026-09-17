import 'package:flutter/foundation.dart';

/// One photographed page inside a document, with its recognised text.
@immutable
class DocumentEntry {
  /// Creates the entry.
  const DocumentEntry({
    required this.id,
    required this.photoPath,
    required this.text,
  });

  final String id;

  /// Stable file path of the photo the entry was scanned from.
  final String photoPath;

  final String text;

  /// The entry's title: the first line of recognised text. The convention is
  /// that the top line of a scan is the heading and everything underneath it
  /// is the body.
  String get title {
    for (final String line in text.split('\n')) {
      final String trimmed = line.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }

  /// Everything underneath the [title] line, as one block. Empty when the
  /// scan recognised a single line only.
  String get description {
    final List<String> lines = text.split('\n');
    final int titleIndex = lines.indexWhere(
      (String line) => line.trim().isNotEmpty,
    );
    if (titleIndex < 0) {
      return '';
    }
    return lines.skip(titleIndex + 1).join('\n').trim();
  }
}

/// A named collection of photographed pages and their recognised text.
@immutable
class ScanDocument {
  /// Creates the document.
  const ScanDocument({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.entries,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final List<DocumentEntry> entries;

  /// Copies the document with a new [name] or [entries].
  ScanDocument copyWith({String? name, List<DocumentEntry>? entries}) {
    return ScanDocument(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      entries: entries ?? this.entries,
    );
  }
}
