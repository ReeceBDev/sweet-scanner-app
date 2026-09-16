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
