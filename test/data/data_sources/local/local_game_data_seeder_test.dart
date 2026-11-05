import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/data_sources/local/database_campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/local_game_data_seeder.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('seeds the bundled campaign and starter idempotently', () async {
    final seeder = LocalGameDataSeeder(
      database,
      contentDataSource: AssetCampaignContentDataSource(),
    );
    final content = DriftCampaignContentDataSource(database);

    await seeder.seed();
    await seeder.seed();

    expect(await database.select(database.characters).get(), hasLength(8));
    expect(await database.select(database.abilities).get(), hasLength(8));
    expect(
      (await database.select(database.characters).get())
          .singleWhere(
            (character) => character.id == CampaignHeroCatalog.starter.id,
          )
          .abilityId,
      CampaignHeroCatalog.starter.abilityId,
    );

    final stage = (await content.loadStages()).single;
    expect(stage.id, 'stage_1');
    expect(stage.mapKey, 'forest');
    expect(stage.rounds, hasLength(5));
    expect(stage.roundByNumber(5)?.isBoss, isTrue);
    expect(stage.enemyById('elder_torch_boss')?.filename, 'torch_purple');
    expect(await database.select(database.monsters).get(), hasLength(5));
    expect(await database.select(database.stageRounds).get(), hasLength(5));
    expect(await database.select(database.roundEncounters).get(), hasLength(6));
    expect(await database.select(database.stageRewards).get(), hasLength(2));
    expect(
      (await database.select(database.playerCharacters).getSingle())
          .characterId,
      CampaignHeroCatalog.starter.id,
    );

    final player = await database.select(database.playerStates).getSingle();
    expect(player.gold, 0);
    expect(player.statusPoints, 0);
    expect(player.selectedHeroId, CampaignHeroCatalog.starter.id);
  });

  test(
    'content refresh preserves local balances, clears, and upgrades',
    () async {
      final seeder = LocalGameDataSeeder(
        database,
        contentDataSource: AssetCampaignContentDataSource(),
      );
      await seeder.seed();
      await (database.update(database.playerStates)
            ..where((row) => row.id.equals(1)))
          .write(const PlayerStatesCompanion(gold: Value(35)));
      await (database.update(database.playerCharacters)..where(
            (row) => row.characterId.equals(CampaignHeroCatalog.starter.id),
          ))
          .write(const PlayerCharactersCompanion(hp: Value(106)));
      await database
          .into(database.campaignStageClears)
          .insert(
            CampaignStageClearsCompanion.insert(
              stageId: 'stage_1',
              completedAt: 123,
            ),
          );

      await seeder.seed();

      expect(
        (await database.select(database.playerStates).getSingle()).gold,
        35,
      );
      expect(
        (await database.select(database.playerCharacters).getSingle()).hp,
        106,
      );
      expect(
        await database.select(database.campaignStageClears).get(),
        hasLength(1),
      );
    },
  );

  test(
    'migrates starter ownership to the exported hero and keeps upgrades',
    () async {
      final seeder = LocalGameDataSeeder(
        database,
        contentDataSource: AssetCampaignContentDataSource(),
      );
      await seeder.seed();

      await (database.delete(database.playerCharacters)..where(
            (row) => row.characterId.equals(CampaignHeroCatalog.starter.id),
          ))
          .go();
      await database
          .into(database.characters)
          .insert(
            CharactersCompanion.insert(
              id: CampaignHeroCatalog.legacyStarterId,
              name: 'Blue Warrior',
              filename: 'warrior_blue',
              price: 0,
              baseHp: 100,
              baseStr: 10,
              baseVit: 3,
              baseAgi: 4,
            ),
          );
      await database
          .into(database.playerCharacters)
          .insert(
            PlayerCharactersCompanion.insert(
              characterId: CampaignHeroCatalog.legacyStarterId,
              hp: 106,
              strength: 11,
              vitality: 3,
              agility: 6,
              statusPoints: 5,
              acquiredAt: 10,
            ),
          );
      await (database.update(
        database.playerStates,
      )..where((row) => row.id.equals(1))).write(
        const PlayerStatesCompanion(
          gold: Value(75),
          statusPoints: Value(3),
          selectedHeroId: Value(CampaignHeroCatalog.legacyStarterId),
        ),
      );

      await seeder.seed();

      final owned = await database
          .select(database.playerCharacters)
          .getSingle();
      final player = await database.select(database.playerStates).getSingle();
      expect(owned.characterId, CampaignHeroCatalog.starter.id);
      expect(owned.hp, 226);
      expect(owned.strength, 21);
      expect(owned.vitality, 10);
      expect(owned.agility, 122);
      expect(owned.statusPoints, 5);
      expect(player.gold, 75);
      expect(player.statusPoints, 3);
      expect(player.selectedHeroId, CampaignHeroCatalog.starter.id);
      expect(
        await (database.select(database.characters)..where(
              (row) => row.id.equals(CampaignHeroCatalog.legacyStarterId),
            ))
            .get(),
        isEmpty,
      );
    },
  );

  test('invalid content leaves all tables unchanged', () async {
    final seeder = LocalGameDataSeeder(
      database,
      contentDataSource: _InvalidCampaignContentDataSource(),
    );

    await expectLater(seeder.seed(), throwsA(isA<CampaignContentException>()));

    expect(await database.select(database.stages).get(), isEmpty);
    expect(await database.select(database.monsters).get(), isEmpty);
    expect(await database.select(database.playerStates).get(), isEmpty);
  });
}

class _InvalidCampaignContentDataSource implements CampaignContentDataSource {
  @override
  Future<List<CampaignStageModel>> loadStages() async => [
    const CampaignStageModel(
      id: 'bad_stage',
      order: 1,
      name: 'Broken map',
      mapKey: 'missing_map',
      enemies: [
        MonsterModel(id: 'enemy', name: 'Enemy', filename: 'torch_blue', hp: 1),
      ],
      rounds: [
        StageRoundModel(
          id: 'bad_stage_round_1',
          number: 1,
          encounters: [
            StageEncounterModel(enemyId: 'enemy', spawnMarker: 'torch_blue'),
          ],
        ),
      ],
    ),
  ];
}
