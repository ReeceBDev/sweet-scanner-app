import 'package:flutter/foundation.dart';

import 'package:sweet_scanner_app/data/documents/scan_document_repository.dart';
import 'package:sweet_scanner_app/state/document/scan_document.dart';

/// Load state of the document editor.
enum DocumentLoadPhase { loading, ready, notFound }

/// Loads one document and owns its edits: renaming and entry deletion, plus
/// the merged text used for export.
final class DocumentEditorController extends ChangeNotifier {
  /// Creates the controller; call [load] once after construction.
  DocumentEditorController({required ScanDocumentRepository repository})
      : _repository = repository;

  final ScanDocumentRepository _repository;

  DocumentLoadPhase _phase = DocumentLoadPhase.loading;
  ScanDocument? _document;

  /// The current load phase.
  DocumentLoadPhase get phase => _phase;

  /// The loaded document, or null until ready.
  ScanDocument? get document => _document;

  /// The document's entries in capture order.
  List<DocumentEntry> get entries =>
      _document?.entries ?? const <DocumentEntry>[];

  /// Every entry's text merged into one block.
  String get mergedText =>
      _document?.entries
          .map((DocumentEntry entry) => entry.text)
          .join('\n\n') ??
      '';

  /// Loads the document with [id].
  Future<void> load(String id) async {
    _phase = DocumentLoadPhase.loading;
    notifyListeners();
    _document = await _repository.get(id);
    _phase = _document == null
        ? DocumentLoadPhase.notFound
        : DocumentLoadPhase.ready;
    notifyListeners();
  }

  /// Renames the document; empty names are ignored.
  Future<void> rename(String name) async {
    final ScanDocument? document = _document;
    final String trimmed = name.trim();
    if (document == null || trimmed.isEmpty) {
      return;
    }
    _document = await _repository.rename(document.id, trimmed);
    notifyListeners();
  }

  /// Deletes one entry from the document.
  Future<void> deleteEntry(String entryId) async {
    final ScanDocument? document = _document;
    if (document == null) {
      return;
    }
    _document = await _repository.deleteEntry(document.id, entryId);
    notifyListeners();
  }
}
