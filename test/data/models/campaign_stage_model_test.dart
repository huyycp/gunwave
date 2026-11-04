import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';

void main() {
  test('CampaignStageModel JSON round-trips local stage content', () {
    const stage = CampaignStageModel(
      id: 'stage_1',
      order: 1,
      name: 'Forest Outskirts',
      mapKey: 'forest',
      enemies: [
        MonsterModel(
          id: 'elder_torch_boss',
          name: 'Elder Torch',
          filename: 'torch_purple',
          hp: 24,
          str: 3,
          vit: 2,
          agi: 1,
          score: 100,
        ),
      ],
      rounds: [
        StageRoundModel(
          id: 'stage_1_round_1',
          number: 1,
          encounters: [
            StageEncounterModel(
              enemyId: 'elder_torch_boss',
              spawnMarker: 'torch_blue',
            ),
          ],
        ),
      ],
      rewards: [RewardModel(type: RewardType.gold, amount: 100)],
    );

    final restored = CampaignStageModel.fromJson(stage.toJson());

    expect(restored, stage);
    expect(restored.map, GameMaps.forest);
    expect(
      restored.enemyById('elder_torch_boss')?.monster?.name,
      'torch_purple',
    );
    expect(
      restored.roundByNumber(1)?.encounters.single.spawnMarker,
      'torch_blue',
    );
    expect(restored.roundByNumber(2), isNull);
  });

  test('CampaignStageModel returns no map for an unknown local map key', () {
    const stage = CampaignStageModel(mapKey: 'missing_map');

    expect(stage.map, isNull);
  });
}
