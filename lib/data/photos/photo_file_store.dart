import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Persists captured photos and exported images under the app's documents
/// directory and hands back stable file paths.
final class PhotoFileStore {
  int _sequence = 0;

  /// Copies a camera capture into persistent storage and returns its path.
  Future<String> saveCapture(Uint8List bytes) async {
    final Directory directory = await _directory('photos');
    final File file = File('${directory.path}/capture-${_stamp()}.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Writes exported PNG bytes to persistent storage and returns the path.
  Future<String> savePng(Uint8List bytes) async {
    final Directory directory = await _directory('exports');
    final File file = File('${directory.path}/merged-${_stamp()}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Deletes the file at [path], ignoring a missing file.
  Future<void> delete(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _directory(String name) async {
    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory directory = Directory('${documents.path}/$name');
    await directory.create(recursive: true);
    return directory;
  }

  String _stamp() {
    _sequence += 1;
    return '${DateTime.now().microsecondsSinceEpoch}-$_sequence';
  }
}
