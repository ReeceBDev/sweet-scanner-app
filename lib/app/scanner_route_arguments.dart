import 'package:flutter/foundation.dart';

/// Typed arguments for the document screen route.
@immutable
class DocumentRouteArgs {
  /// Creates the arguments.
  const DocumentRouteArgs({required this.documentId});

  final String documentId;
}
