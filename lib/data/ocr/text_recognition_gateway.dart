/// Thrown when on-device text recognition fails or is unavailable.
class TextRecognitionException implements Exception {
  /// Creates the exception with a human-readable [message].
  const TextRecognitionException(this.message);

  final String message;

  @override
  String toString() => 'TextRecognitionException: $message';
}

/// Abstract on-device text recogniser.
///
/// Dependency inversion: the state layer depends on this interface, never on
/// a concrete platform implementation.
abstract interface class TextRecognitionGateway {
  /// Recognises the text in the image at [imagePath] and returns it as one
  /// string.
  Future<String> recognize(String imagePath);
}
