import 'package:flutter/foundation.dart';

import 'package:sweet_scanner_app/data/documents/scan_document_repository.dart';
import 'package:sweet_scanner_app/state/document/scan_document.dart';

/// Load state of the library.
enum LibraryPhase { loading, ready, failed }

/// Lists every named document, newest first.
final class LibraryController extends ChangeNotifier {
  /// Creates the controller; call [refresh] once after construction.
  LibraryController({required ScanDocumentRepository repository})
      : _repository = repository;

  final ScanDocumentRepository _repository;

  LibraryPhase _phase = LibraryPhase.loading;
  List<ScanDocument> _documents = const <ScanDocument>[];

  /// The current load phase.
  LibraryPhase get phase => _phase;

  /// Every named document, newest first.
  List<ScanDocument> get documents => _documents;

  /// Reloads the library from storage.
  Future<void> refresh() async {
    _phase = LibraryPhase.loading;
    notifyListeners();
    try {
      _documents = await _repository.getAll();
      _phase = LibraryPhase.ready;
    } on Exception {
      _phase = LibraryPhase.failed;
    }
    notifyListeners();
  }
}
