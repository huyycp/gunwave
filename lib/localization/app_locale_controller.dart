import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the selected language mode and exposes its locale to the app.
///
/// A `null` locale means Flutter should follow the device language. The mode
/// is stored locally so users can change language before signing in.
class AppLocaleController extends ChangeNotifier {
  AppLocaleController({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _preferenceKey = 'app_locale_mode';

  final SharedPreferencesAsync _preferences;
  Future<void> _pendingWrite = Future<void>.value();
  AppLocaleMode _mode = AppLocaleMode.system;

  /// The currently selected language mode.
  AppLocaleMode get mode => _mode;

  /// The locale override, or `null` when the app follows the device locale.
  Locale? get locale => switch (_mode) {
    AppLocaleMode.system => null,
    AppLocaleMode.english => const Locale('en'),
    AppLocaleMode.vietnamese => const Locale('vi'),
  };

  /// Loads the saved language mode, defaulting to device language if invalid.
  Future<void> load() async {
    try {
      final savedMode = await _preferences.getString(_preferenceKey);
      _mode = AppLocaleMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => AppLocaleMode.system,
      );
    } catch (error) {
      debugPrint('Unable to load saved language preference: $error');
      _mode = AppLocaleMode.system;
    }
  }

  /// Saves [mode] and updates the app's locale immediately.
  Future<void> setMode(AppLocaleMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    // Serialize writes: a slower earlier choice must not overwrite the latest.
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await _preferences.setString(_preferenceKey, mode.name);
      } catch (error) {
        debugPrint('Unable to save language preference: $error');
      }
    });
    await _pendingWrite;
  }
}

/// Provides the app's persisted language-mode controller.
final appLocaleControllerProvider = ChangeNotifierProvider<AppLocaleController>(
  (ref) => AppLocaleController(),
);
