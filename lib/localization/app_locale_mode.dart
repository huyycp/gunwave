/// Defines whether Gunwave uses the device locale or a selected app language.
enum AppLocaleMode {
  /// Follows the device locale and falls back to English when unsupported.
  system,

  /// Uses English regardless of the device locale.
  english,

  /// Uses Vietnamese regardless of the device locale.
  vietnamese,
}
