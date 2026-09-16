import 'package:flutter/material.dart';

/// Pre-declared colour tokens for the Sweet Scanner wireframe design.
///
/// Every colour used in the app must reference a token declared here; no
/// widget may declare its own [Color] literal.
abstract final class AppColors {
  /// Page and component background: pure white.
  static const Color background = Color(0xFFFFFFFF);

  /// Lines, borders and text: pure black.
  static const Color ink = Color(0xFF000000);

  /// Disabled controls, hints and failure text: grey.
  static const Color disabled = Color(0xFF9E9E9E);
}
