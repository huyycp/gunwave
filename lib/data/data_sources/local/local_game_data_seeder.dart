import 'package:drift/drift.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/repositories/campaign_repository.dart';

/// Copies bundled static game definitions into SQLite without replacing player data.
class LocalGameDataSeeder {
  const LocalGameDataSeeder(this._database, {required this._contentDataSource});

  final AppDatabase _database;
  final CampaignContentDataSource _contentDataSource;

  Future<void> seed() async {
    final stages = await CampaignRepository(_contentDataSource).getStages();
    await _database.transaction(() async {
      for (final stage in stages) {
        await _seedStage(stage);
      }
      await _seedStarterHero();
    });
  }

  Future<void> _seedStage(CampaignStageModel stage) async {
    await _database
        .into(_database.stages)
        .insertOnConflictUpdate(
          StagesCompanion.insert(
            id: stage.id,
            stageOrder: stage.order,
            name: stage.name,
            mapKey: stage.mapKey,
            unlockRequirementStageId: Value(stage.unlockRequirementStageId),
          ),
        );

    for (final monster in stage.enemies) {
      await _database
          .into(_database.monsters)
          .insertOnConflictUpdate(
            MonstersCompanion.insert(
              id: monster.id,
              name: monster.name,
              filename: monster.filename,
              hp: monster.hp,
              strength: monster.str,
              vitality: monster.vit,
              agility: monster.agi,
              score: monster.score,
            ),
          );
      await _database
          .into(_database.stageMonsters)
          .insertOnConflictUpdate(
            StageMonstersCompanion.insert(
              stageId: stage.id,
              monsterId: monster.id,
            ),
          );
    }

    for (final round in stage.rounds) {
      await _database
          .into(_database.stageRounds)
          .insertOnConflictUpdate(
            StageRoundsCompanion.insert(
              id: round.id,
              stageId: stage.id,
              roundNumber: round.number,
              isBoss: round.isBoss,
            ),
          );
      for (var index = 0; index < round.encounters.length; index++) {
        final encounter = round.encounters[index];
        await _database
            .into(_database.roundEncounters)
            .insertOnConflictUpdate(
              RoundEncountersCompanion.insert(
                roundId: round.id,
                encounterOrder: index,
                monsterId: encounter.enemyId,
                spawnMarker: encounter.spawnMarker,
                count: encounter.count,
              ),
            );
      }
    }

    for (var index = 0; index < stage.rewards.length; index++) {
      final reward = stage.rewards[index];
      await _database
          .into(_database.stageRewards)
          .insertOnConflictUpdate(
            StageRewardsCompanion.insert(
              stageId: stage.id,
              rewardOrder: index,
              type: reward.type.name,
              amount: reward.amount,
            ),
          );
    }
  }

  Future<void> _seedStarterHero() async {
    const starter = CampaignHeroCatalog.starter;
    await _database
        .into(_database.characters)
        .insertOnConflictUpdate(
          CharactersCompanion.insert(
            id: starter.id,
            name: starter.name,
            filename: starter.filename,
            price: starter.price,
            baseHp: starter.hp,
            baseStr: starter.str,
            baseVit: starter.vit,
            baseAgi: starter.agi,
          ),
        );
    await _database
        .into(_database.playerStates)
        .insert(
          PlayerStatesCompanion.insert(
            id: const Value(1),
            gold: 0,
            statusPoints: 0,
            selectedHeroId: Value(starter.id),
          ),
          mode: InsertMode.insertOrIgnore,
        );

    final ownedCharacters = await _database
        .select(_database.playerCharacters)
        .get();
    if (ownedCharacters.isEmpty) {
      await _database
          .into(_database.playerCharacters)
          .insert(
            PlayerCharactersCompanion.insert(
              characterId: starter.id,
              hp: starter.hp,
              strength: starter.str,
              vitality: starter.vit,
              agility: starter.agi,
              statusPoints: starter.sp,
              acquiredAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
    }

    final playerState = await _database
        .select(_database.playerStates)
        .getSingle();
    if (playerState.selectedHeroId == null) {
      await (_database.update(_database.playerStates)
            ..where((row) => row.id.equals(1)))
          .write(PlayerStatesCompanion(selectedHeroId: Value(starter.id)));
    }
  }
}
