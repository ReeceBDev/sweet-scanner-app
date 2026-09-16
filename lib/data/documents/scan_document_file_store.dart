import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:sweet_scanner_app/data/documents/scan_document_dto.dart';

/// Reads and writes one JSON file per scan document under the documents
/// directory. Knows nothing about business rules.
final class ScanDocumentFileStore {
  /// Reads every stored document, skipping corrupt files.
  Future<List<ScanDocumentDto>> readAll() async {
    final Directory directory = await _directory();
    final List<ScanDocumentDto> documents = <ScanDocumentDto>[];
    final List<FileSystemEntity> entities = await directory.list().toList();
    for (final File file in entities.whereType<File>()) {
      try {
        final Map<String, dynamic> json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        documents.add(ScanDocumentDto.fromJson(json));
      } on FormatException {
        // A corrupt file is skipped rather than breaking the library.
      }
    }
    return documents;
  }

  /// Writes [document] as its own JSON file.
  Future<void> write(ScanDocumentDto document) async {
    final Directory directory = await _directory();
    final File file = File('${directory.path}/${document.id}.json');
    await file.writeAsString(jsonEncode(document.toJson()));
  }

  /// Deletes the JSON file of the document with [id], ignoring a missing
  /// file.
  Future<void> delete(String id) async {
    final Directory directory = await _directory();
    final File file = File('${directory.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _directory() async {
    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory directory = Directory('${documents.path}/documents');
    await directory.create(recursive: true);
    return directory;
  }
}
