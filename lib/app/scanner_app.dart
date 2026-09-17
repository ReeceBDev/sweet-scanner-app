import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:sweet_scanner_app/app/scanner_routes.dart';
import 'package:sweet_scanner_app/data/documents/scan_document_file_store.dart';
import 'package:sweet_scanner_app/data/documents/scan_document_repository.dart';
import 'package:sweet_scanner_app/data/ocr/text_recognition_gateway.dart';
import 'package:sweet_scanner_app/data/ocr/vision_text_recognition_gateway.dart';
import 'package:sweet_scanner_app/data/photos/photo_file_store.dart';
import 'package:sweet_scanner_app/theme/theme.dart';

/// Root widget of the app: builds the dependencies once, exposes them through
/// providers and wires the global theme and the central route table.
///
/// The app's root is the camera.
class ScannerApp extends StatelessWidget {
  /// Creates the app root.
  const ScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<PhotoFileStore>(create: (_) => PhotoFileStore()),
        Provider<ScanDocumentFileStore>(create: (_) => ScanDocumentFileStore()),
        Provider<TextRecognitionGateway>(
          create: (_) => VisionTextRecognitionGateway(),
        ),
        Provider<ScanDocumentRepository>(
          create: (BuildContext context) => ScanDocumentRepository(
            store: Provider.of<ScanDocumentFileStore>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Sweet Scanner',
        theme: AppTheme.light(),
        onGenerateRoute: ScannerRoutes.resolve,
      ),
    );
  }
}
