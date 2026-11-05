import 'package:drift/drift.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';

/// Reads immutable campaign definitions from the local SQLite catalog.
class DriftCampaignContentDataSource implements CampaignContentDataSource {
  const DriftCampaignContentDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<List<CampaignStageModel>> loadStages() async {
    final stageRows = await (_database.select(
      _database.stages,
    )..orderBy([(stage) => OrderingTerm.asc(stage.stageOrder)])).get();
    final result = <CampaignStageModel>[];

    for (final stage in stageRows) {
      result.add(
        CampaignStageModel(
          id: stage.id,
          order: stage.stageOrder,
          name: stage.name,
          mapKey: stage.mapKey,
          unlockRequirementStageId: stage.unlockRequirementStageId,
          enemies: await _loadStageMonsters(stage.id),
          rounds: await _loadRounds(stage.id),
          rewards: await _loadRewards(stage.id),
        ),
      );
    }
    return result;
  }

  Future<List<MonsterModel>> _loadStageMonsters(String stageId) async {
    final rows =
        await (_database.select(_database.stageMonsters).join([
                innerJoin(
                  _database.monsters,
                  _database.monsters.id.equalsExp(
                    _database.stageMonsters.monsterId,
                  ),
                ),
              ])
              ..where(_database.stageMonsters.stageId.equals(stageId))
              ..orderBy([OrderingTerm.asc(_database.monsters.id)]))
            .get();
    return rows
        .map((row) {
          final monster = row.readTable(_database.monsters);
          return MonsterModel(
            id: monster.id,
            name: monster.name,
            filename: monster.filename,
            hp: monster.hp,
            str: monster.strength,
            vit: monster.vitality,
            agi: monster.agility,
            score: monster.score,
          );
        })
        .toList(growable: false);
  }

  Future<List<StageRoundModel>> _loadRounds(String stageId) async {
    final roundRows =
        await (_database.select(_database.stageRounds)
              ..where((round) => round.stageId.equals(stageId))
              ..orderBy([(round) => OrderingTerm.asc(round.roundNumber)]))
            .get();
    final result = <StageRoundModel>[];

    for (final round in roundRows) {
      final encounters =
          await (_database.select(_database.roundEncounters)
                ..where((encounter) => encounter.roundId.equals(round.id))
                ..orderBy([
                  (encounter) => OrderingTerm.asc(encounter.encounterOrder),
                ]))
              .get();
      result.add(
        StageRoundModel(
          id: round.id,
          number: round.roundNumber,
          isBoss: round.isBoss,
          encounters: encounters
              .map(
                (encounter) => StageEncounterModel(
                  enemyId: encounter.monsterId,
                  spawnMarker: encounter.spawnMarker,
                  count: encounter.count,
                ),
              )
              .toList(growable: false),
        ),
      );
    }
    return result;
  }

  Future<List<RewardModel>> _loadRewards(String stageId) async {
    final rows =
        await (_database.select(_database.stageRewards)
              ..where((reward) => reward.stageId.equals(stageId))
              ..orderBy([(reward) => OrderingTerm.asc(reward.rewardOrder)]))
            .get();
    return rows
        .map(
          (reward) => RewardModel(
            type: RewardType.values.firstWhere(
              (type) => type.name == reward.type,
              orElse: () => RewardType.unknown,
            ),
            amount: reward.amount,
          ),
        )
        .toList(growable: false);
  }
}
