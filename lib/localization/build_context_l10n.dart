import 'package:flutter/widgets.dart';
import 'package:gunwave/l10n/app_localizations.dart';

/// Provides the generated localized strings for a widget's current locale.
extension BuildContextL10n on BuildContext {
  /// The generated strings resolved from this context's locale.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
