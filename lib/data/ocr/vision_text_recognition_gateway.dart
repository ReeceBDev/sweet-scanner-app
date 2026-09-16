import 'package:flutter/services.dart';

import 'package:sweet_scanner_app/data/ocr/text_recognition_gateway.dart';

/// iOS implementation over the phone's built-in OCR (Apple's Vision
/// framework), reached through the `sweet_scanner_app/ocr` method channel
/// handled natively in ios/Runner.
final class VisionTextRecognitionGateway implements TextRecognitionGateway {
  static const MethodChannel _channel = MethodChannel('sweet_scanner_app/ocr');

  @override
  Future<String> recognize(String imagePath) async {
    try {
      final Object? text = await _channel.invokeMethod<Object>(
        'recognizeText',
        <String, Object>{'path': imagePath},
      );
      if (text is String) {
        return text;
      }
      throw const TextRecognitionException('Unexpected OCR response.');
    } on PlatformException catch (error) {
      throw TextRecognitionException(
        error.message ?? 'Text recognition failed.',
      );
    } on MissingPluginException {
      throw const TextRecognitionException(
        'Text recognition is only available on iOS.',
      );
    }
  }
}
