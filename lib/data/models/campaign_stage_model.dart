import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';

part 'campaign_stage_model.freezed.dart';
part 'campaign_stage_model.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Holds the local map, enemies, rounds, unlock rule, and rewards for a stage.
@freezed
abstract class CampaignStageModel with _$CampaignStageModel {
  const CampaignStageModel._();

  /// Creates an immutable campaign stage definition.
  @JsonSerializable(explicitToJson: true)
  const factory CampaignStageModel({
    @Default('') String id,
    @Default(0) int order,
    @Default('') String name,
    @Default('') String mapKey,
    String? unlockRequirementStageId,
    @Default(<MonsterModel>[]) List<MonsterModel> enemies,
    @Default(<StageRoundModel>[]) List<StageRoundModel> rounds,
    @Default(<RewardModel>[]) List<RewardModel> rewards,
  }) = _CampaignStageModel;

  /// Parses a stage and its nested local campaign content.
  factory CampaignStageModel.fromJson(Map<String, dynamic> json) =>
      _$CampaignStageModelFromJson(json);

  /// Resolves [mapKey] only when it matches a playable local map.
  GameMaps? get map {
    for (final candidate in GameMaps.values) {
      if (candidate.name == mapKey) return candidate;
    }
    return null;
  }

  /// Finds an enemy definition by its stage-local identifier.
  MonsterModel? enemyById(String enemyId) {
    for (final enemy in enemies) {
      if (enemy.id == enemyId) return enemy;
    }
    return null;
  }

  /// Finds a round by its one-based display number.
  StageRoundModel? roundByNumber(int roundNumber) {
    for (final round in rounds) {
      if (round.number == roundNumber) return round;
    }
    return null;
  }
}
