import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/legacy_preferences_migrator.dart';
import 'package:gunwave/data/data_sources/local/local_game_data_seeder.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prepares local content and settings before the app builds its first screen.
class LocalAppInitializer {
  const LocalAppInitializer(
    this._database, {
    this._contentDataSource,
    this._legacyPreferences,
  });

  final AppDatabase _database;
  final CampaignContentDataSource? _contentDataSource;
  final SharedPreferencesAsync? _legacyPreferences;

  Future<AppLocaleController> initialize() async {
    await LocalGameDataSeeder(
      _database,
      contentDataSource: _contentDataSource ?? AssetCampaignContentDataSource(),
    ).seed();
    await LegacyPreferencesMigrator(
      _database,
      preferences: _legacyPreferences,
    ).migrate();
    final localeController = AppLocaleController(_database);
    await localeController.load();
    return localeController;
  }
}
