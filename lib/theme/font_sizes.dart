/// Pre-declared font size tokens for the Sweet Scanner wireframe design.
///
/// Every text size used in the app must reference a token declared here; no
/// widget may hardcode its own font size.
abstract final class AppFontSizes {
  /// Badges, captions and hints.
  static const double label = 12;

  /// Body copy: recognised text.
  static const double body = 14;

  /// Entry-level headings and library rows.
  static const double entry = 16;

  /// Screen titles.
  static const double title = 20;

  /// Line height used by body text in the merged text view.
  static const double bodyLineHeight = 1.4;
}
