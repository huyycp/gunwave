import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/database_campaign_content_data_source.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository(
    DriftCampaignContentDataSource(ref.read(appDatabaseProvider)),
  );
});

/// Loads and validates local campaign definitions for game and menu flows.
class CampaignRepository {
  /// Creates a repository backed by [contentDataSource].
  CampaignRepository(this._contentDataSource);

  final CampaignContentDataSource _contentDataSource;

  /// Loads all stages and rejects unresolved local content references.
  Future<List<CampaignStageModel>> getStages() async {
    final stages = await _contentDataSource.loadStages();
    _validateStages(stages);
    return stages;
  }

  /// Loads the stage with [stageId] or throws a recoverable content error.
  Future<CampaignStageModel> getStage(String stageId) async {
    final stages = await getStages();
    for (final stage in stages) {
      if (stage.id == stageId) return stage;
    }
    throw CampaignContentException('Unknown campaign stage "$stageId".');
  }

  /// Loads the numbered round from [stageId] or throws a content error.
  Future<StageRoundModel> getRound(String stageId, int roundNumber) async {
    final stage = await getStage(stageId);
    final round = stage.roundByNumber(roundNumber);
    if (round == null) {
      throw CampaignContentException(
        'Stage "$stageId" has no round $roundNumber.',
      );
    }
    return round;
  }

  void _validateStages(List<CampaignStageModel> stages) {
    if (stages.isEmpty) {
      throw const CampaignContentException(
        'The campaign catalog must include at least one stage.',
      );
    }

    final stagesById = <String, CampaignStageModel>{};
    final stageOrders = <int>{};
    for (final stage in stages) {
      if (stage.id.trim().isEmpty || stagesById.containsKey(stage.id)) {
        throw CampaignContentException(
          'Campaign stage IDs must be non-empty and unique: "${stage.id}".',
        );
      }
      stagesById[stage.id] = stage;
      if (stage.order < 1 || !stageOrders.add(stage.order)) {
        throw CampaignContentException(
          'Campaign stage order must be positive and unique for "${stage.id}".',
        );
      }
      if (stage.name.trim().isEmpty) {
        throw CampaignContentException(
          'Campaign stage "${stage.id}" must have a name.',
        );
      }
      if (!_hasMap(stage.mapKey)) {
        throw CampaignContentException(
          'Stage "${stage.id}" references unknown local map "${stage.mapKey}".',
        );
      }
      if (stage.rounds.isEmpty) {
        throw CampaignContentException(
          'Stage "${stage.id}" must include at least one round.',
        );
      }

      final enemiesById = _validateEnemies(stage);
      _validateRounds(stage, enemiesById);
    }

    for (final stage in stages) {
      final requirement = stage.unlockRequirementStageId;
      final requiredStage = requirement == null
          ? null
          : stagesById[requirement];
      if (requirement != null &&
          (requiredStage == null || requiredStage.order >= stage.order)) {
        throw CampaignContentException(
          'Stage "${stage.id}" has an invalid unlock requirement "$requirement".',
        );
      }
      if (stage.rewards.any(
        (reward) => reward.type == RewardType.unknown || reward.amount < 0,
      )) {
        throw CampaignContentException(
          'Stage "${stage.id}" has an invalid reward definition.',
        );
      }
    }
  }

  Map<String, MonsterModel> _validateEnemies(CampaignStageModel stage) {
    if (stage.enemies.isEmpty) {
      throw CampaignContentException(
        'Stage "${stage.id}" must define at least one local enemy.',
      );
    }

    final enemiesById = <String, MonsterModel>{};
    for (final enemy in stage.enemies) {
      if (enemy.id.trim().isEmpty || enemiesById.containsKey(enemy.id)) {
        throw CampaignContentException(
          'Stage "${stage.id}" has an empty or duplicate enemy ID "${enemy.id}".',
        );
      }
      if (!_hasMonster(enemy.filename)) {
        throw CampaignContentException(
          'Enemy "${enemy.id}" references unknown local sprite "${enemy.filename}".',
        );
      }
      if (enemy.hp < 1 ||
          enemy.str < 0 ||
          enemy.vit < 0 ||
          enemy.agi < 0 ||
          enemy.score < 0) {
        throw CampaignContentException(
          'Enemy "${enemy.id}" has invalid combat stats.',
        );
      }
      enemiesById[enemy.id] = enemy;
    }
    return enemiesById;
  }

  void _validateRounds(
    CampaignStageModel stage,
    Map<String, MonsterModel> enemiesById,
  ) {
    final roundIds = <String>{};
    final bossRounds = stage.rounds.where((round) => round.isBoss).toList();
    if (bossRounds.length > 1 ||
        (bossRounds.isNotEmpty &&
            bossRounds.single.id != stage.rounds.last.id)) {
      throw CampaignContentException(
        'Stage "${stage.id}" can have only one boss round, at the end of the stage.',
      );
    }
    for (var index = 0; index < stage.rounds.length; index++) {
      final round = stage.rounds[index];
      final expectedNumber = index + 1;
      if (round.id.trim().isEmpty || !roundIds.add(round.id)) {
        throw CampaignContentException(
          'Stage "${stage.id}" has an empty or duplicate round ID "${round.id}".',
        );
      }
      if (round.number != expectedNumber) {
        throw CampaignContentException(
          'Stage "${stage.id}" rounds must be ordered from 1; expected round $expectedNumber but found ${round.number}.',
        );
      }
      if (round.encounters.isEmpty) {
        throw CampaignContentException(
          'Stage "${stage.id}" round ${round.number} must include an encounter.',
        );
      }

      for (final encounter in round.encounters) {
        if (!enemiesById.containsKey(encounter.enemyId)) {
          throw CampaignContentException(
            'Round ${round.number} references unknown enemy "${encounter.enemyId}".',
          );
        }
        if (encounter.spawnMarker.trim().isEmpty) {
          throw CampaignContentException(
            'Round ${round.number} has an empty Tiled spawn marker.',
          );
        }
        if (encounter.count < 1) {
          throw CampaignContentException(
            'Round ${round.number} encounter count must be positive.',
          );
        }
      }
    }
  }

  bool _hasMap(String mapKey) =>
      GameMaps.values.any((map) => map.name == mapKey);

  bool _hasMonster(String filename) =>
      GameMonsters.values.any((monster) => monster.name == filename);
}
