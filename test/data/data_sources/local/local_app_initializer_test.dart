import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/data_sources/local/local_app_initializer.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initializes the offline RPG without account or cloud data', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final localeController = await LocalAppInitializer(
      database,
      legacyPreferences: MemoryPreferences(),
    ).initialize();
    addTearDown(localeController.dispose);

    final stage = await database.select(database.stages).getSingle();
    final player = await database.select(database.playerStates).getSingle();
    final owned = await database.select(database.playerCharacters).get();

    expect(stage.id, 'stage_1');
    expect(await database.select(database.stageRounds).get(), hasLength(5));
    expect(player.gold, 0);
    expect(player.statusPoints, 0);
    expect(player.selectedHeroId, CampaignHeroCatalog.starter.id);
    expect(owned, hasLength(1));
    expect(await database.select(database.characters).get(), hasLength(8));
    expect(await database.select(database.abilities).get(), hasLength(8));
    expect(await database.select(database.campaignStageClears).get(), isEmpty);
    expect(localeController.mode, AppLocaleMode.system);
  });
}

class MemoryPreferences implements SharedPreferencesAsync {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<bool> remove(String key) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
