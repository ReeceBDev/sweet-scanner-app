/// Pre-declared size tokens for the Sweet Scanner wireframe design.
///
/// Every dimension used in the app must reference a token declared here; no
/// widget may hardcode its own size.
abstract final class AppSizes {
  /// Small spacing: icon gaps and badge padding.
  static const double spaceXs = 4;

  /// Compact spacing between related controls.
  static const double spaceS = 8;

  /// Standard padding inside cards, popups and rows.
  static const double spaceM = 16;

  /// Generous spacing around screen-level controls.
  static const double spaceL = 24;

  /// Standard hairline border width.
  static const double borderWidth = 1;

  /// Heavy ring width (the shutter's inner ring).
  static const double shutterRingWidth = 3;

  /// Standard corner radius.
  static const double borderRadius = 8;

  /// Standard icon size.
  static const double iconSize = 24;

  /// Gallery badge minimum diameter.
  static const double badgeMinSize = 20;

  /// Primary buttons' height.
  static const double buttonHeight = 48;

  /// Shutter button outer diameter.
  static const double shutterSize = 72;

  /// Shutter button inner ring diameter.
  static const double shutterInnerSize = 58;

  /// Gallery thumbnail height (collapsed photo card, entry tile).
  static const double thumbnailHeight = 84;

  /// Expanded gallery photo height.
  static const double expandedPhotoHeight = 320;

  /// Expanded OCR text box max height.
  static const double expandedTextMaxHeight = 240;

  /// Document entry thumbnail width.
  static const double entryThumbWidth = 72;

  /// Export image render pixel ratio.
  static const double exportPixelRatio = 3;
}
