import 'package:flutter/material.dart';

import 'package:sweet_scanner_app/app/scanner_route_arguments.dart';
import 'package:sweet_scanner_app/pages/camera_page.dart';
import 'package:sweet_scanner_app/pages/document_page.dart';
import 'package:sweet_scanner_app/pages/library_page.dart';

/// Central route configuration for the Sweet Scanner app.
///
/// Every navigation target is declared here so pages navigate by name instead
/// of building routes themselves.
abstract final class ScannerRoutes {
  /// The camera route: the app's first screen.
  static const String camera = '/';

  /// The library route: every named entry.
  static const String library = '/library';

  /// The document screen route.
  static const String document = '/document';

  /// Builds the route registered for [settings.name]; unknown routes fall
  /// back to the camera.
  static Route<void> resolve(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => switch (settings.name) {
        library => const LibraryPage(),
        document => DocumentPage(
            documentId: _documentArgs(settings).documentId,
          ),
        _ => const CameraPage(),
      },
    );
  }

  /// Unwraps the typed document route arguments.
  static DocumentRouteArgs _documentArgs(RouteSettings settings) {
    return settings.arguments! as DocumentRouteArgs;
  }
}
