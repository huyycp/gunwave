import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/localization/app_locale_mode.dart';

/// Stores the selected language mode and exposes its locale to the app.
///
/// A `null` locale means Flutter should follow the device language. The mode
/// is stored in the local Drift database.
class AppLocaleController extends ChangeNotifier {
  AppLocaleController(this._database);

  static const storageKey = 'locale_mode';

  final AppDatabase _database;
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
      final savedMode = await (_database.select(
        _database.settings,
      )..where((setting) => setting.key.equals(storageKey))).getSingleOrNull();
      _mode = _parseMode(savedMode?.value);
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
        await _database
            .into(_database.settings)
            .insertOnConflictUpdate(
              SettingsCompanion.insert(key: storageKey, value: mode.name),
            );
      } catch (error) {
        debugPrint('Unable to save language preference: $error');
      }
    });
    await _pendingWrite;
  }

  static AppLocaleMode _parseMode(String? savedMode) =>
      AppLocaleMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => AppLocaleMode.system,
      );
}

/// Provides the app's persisted language-mode controller.
final appLocaleControllerProvider = ChangeNotifierProvider<AppLocaleController>(
  (ref) => AppLocaleController(ref.read(appDatabaseProvider)),
);
