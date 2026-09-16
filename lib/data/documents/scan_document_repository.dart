import 'package:sweet_scanner_app/data/documents/scan_document_dto.dart';
import 'package:sweet_scanner_app/data/documents/scan_document_file_store.dart';
import 'package:sweet_scanner_app/state/document/scan_document.dart';

/// The only document API the state layer sees.
///
/// Maps stored DTOs to state models and owns the business rules: id
/// generation, ordering, renaming and entry deletion.
final class ScanDocumentRepository {
  /// Creates the repository over [store].
  ScanDocumentRepository({required ScanDocumentFileStore store})
      : _store = store;

  final ScanDocumentFileStore _store;

  /// Creates a document from a finished capture session's entries.
  Future<ScanDocument> create({
    required String name,
    required List<DocumentEntry> entries,
  }) async {
    final ScanDocument document = ScanDocument(
      id: 'doc-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      createdAt: DateTime.now(),
      entries: List<DocumentEntry>.of(entries),
    );
    await _store.write(_toDto(document));
    return document;
  }

  /// Every document, newest first.
  Future<List<ScanDocument>> getAll() async {
    final List<ScanDocument> documents =
        (await _store.readAll()).map(_fromDto).toList()
          ..sort(
            (ScanDocument a, ScanDocument b) =>
                b.createdAt.compareTo(a.createdAt),
          );
    return documents;
  }

  /// The document with [id], or null when it does not exist.
  Future<ScanDocument?> get(String id) async {
    for (final ScanDocumentDto dto in await _store.readAll()) {
      if (dto.id == id) {
        return _fromDto(dto);
      }
    }
    return null;
  }

  /// Renames the document with [id] and hands back the updated document.
  Future<ScanDocument> rename(String id, String name) async {
    final ScanDocument? document = await get(id);
    if (document == null) {
      throw StateError('Document $id not found.');
    }
    final ScanDocument renamed = document.copyWith(name: name);
    await _store.write(_toDto(renamed));
    return renamed;
  }

  /// Deletes one entry from the document with [id] and hands back the
  /// updated document.
  Future<ScanDocument> deleteEntry(String id, String entryId) async {
    final ScanDocument? document = await get(id);
    if (document == null) {
      throw StateError('Document $id not found.');
    }
    final ScanDocument updated = document.copyWith(
      entries: document.entries
          .where((DocumentEntry entry) => entry.id != entryId)
          .toList(),
    );
    await _store.write(_toDto(updated));
    return updated;
  }

  ScanDocumentDto _toDto(ScanDocument document) {
    return ScanDocumentDto(
      id: document.id,
      name: document.name,
      createdAtIso: document.createdAt.toIso8601String(),
      entries: document.entries
          .map(
            (DocumentEntry entry) => ScanDocumentEntryDto(
              id: entry.id,
              photoPath: entry.photoPath,
              text: entry.text,
            ),
          )
          .toList(),
    );
  }

  ScanDocument _fromDto(ScanDocumentDto dto) {
    return ScanDocument(
      id: dto.id,
      name: dto.name,
      createdAt: DateTime.parse(dto.createdAtIso),
      entries: dto.entries
          .map(
            (ScanDocumentEntryDto entry) => DocumentEntry(
              id: entry.id,
              photoPath: entry.photoPath,
              text: entry.text,
            ),
          )
          .toList(),
    );
  }
}
