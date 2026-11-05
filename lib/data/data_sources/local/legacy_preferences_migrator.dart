import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

final legacyPreferencesMigratorProvider = Provider<LegacyPreferencesMigrator>(
  (ref) => LegacyPreferencesMigrator(
    ref.read(appDatabaseProvider),
    preferences: SharedPreferencesAsync(),
  ),
);

/// Imports the saved locale once and discards obsolete serialized RPG progress.
class LegacyPreferencesMigrator {
  LegacyPreferencesMigrator(
    this._database, {
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _migrationMarker = 'legacy_preferences_migrated_v1';
  static const _legacyLocaleKey = 'app_locale_mode';
  static const _legacyCampaignProgressKey = 'campaign_progress_v1';

  final AppDatabase _database;
  final SharedPreferencesAsync _preferences;

  Future<void> migrate() async {
    final existingMarker =
        await (_database.select(_database.appMetadata)
              ..where((metadata) => metadata.key.equals(_migrationMarker)))
            .getSingleOrNull();
    if (existingMarker != null) return;

    String? legacyLocale;
    try {
      legacyLocale = await _preferences.getString(_legacyLocaleKey);
    } catch (error) {
      debugPrint('Unable to read legacy locale setting: $error');
    }
    AppLocaleMode? localeMode;
    for (final mode in AppLocaleMode.values) {
      if (mode.name == legacyLocale) {
        localeMode = mode;
        break;
      }
    }

    await _database.transaction(() async {
      final marker =
          await (_database.select(_database.appMetadata)
                ..where((metadata) => metadata.key.equals(_migrationMarker)))
              .getSingleOrNull();
      if (marker != null) return;

      if (localeMode != null) {
        await _database
            .into(_database.settings)
            .insert(
              SettingsCompanion.insert(
                key: AppLocaleController.storageKey,
                value: localeMode.name,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      await _database
          .into(_database.appMetadata)
          .insert(
            AppMetadataCompanion.insert(
              key: _migrationMarker,
              value: 'complete',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });

    try {
      await _preferences.remove(_legacyCampaignProgressKey);
      await _preferences.remove(_legacyLocaleKey);
    } catch (error) {
      debugPrint('Unable to clear legacy local preferences: $error');
    }
  }
}
