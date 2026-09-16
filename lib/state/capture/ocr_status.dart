/// Recognition state of one captured photo.
enum OcrStatus {
  /// Recognition is running.
  running,

  /// Recognition finished; the text is available.
  done,

  /// Recognition failed; it can be retried.
  failed,
}
