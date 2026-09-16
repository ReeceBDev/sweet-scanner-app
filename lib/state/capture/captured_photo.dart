import 'package:flutter/foundation.dart';

import 'package:sweet_scanner_app/state/capture/ocr_status.dart';

/// One photo captured during the current camera session, with its OCR state.
@immutable
class CapturedPhoto {
  /// Creates the photo; recognition starts out [OcrStatus.running].
  const CapturedPhoto({
    required this.id,
    required this.path,
    this.status = OcrStatus.running,
    this.text = '',
  });

  final String id;

  /// Stable file path of the persisted capture.
  final String path;

  final OcrStatus status;

  /// The recognised text, once recognition has finished.
  final String text;

  /// Copies the photo with new recognition state.
  CapturedPhoto copyWith({OcrStatus? status, String? text}) {
    return CapturedPhoto(
      id: id,
      path: path,
      status: status ?? this.status,
      text: text ?? this.text,
    );
  }
}
