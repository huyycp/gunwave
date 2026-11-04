import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';
import 'package:gunwave/repositories/campaign_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads Stage 1 as five ordered rounds with a Round 5 boss', () async {
    final stages = await CampaignRepository(AssetCampaignContentDataSource())
        .getStages();
    final stage = stages.single;

    expect(stage.id, 'stage_1');
    expect(stage.mapKey, 'forest');
    expect(stage.rounds.map((round) => round.number), [1, 2, 3, 4, 5]);
    expect(stage.roundByNumber(5)?.isBoss, isTrue);
    expect(stage.enemyById('elder_torch_boss')?.filename, 'torch_purple');
    final bossRound = await CampaignRepository(AssetCampaignContentDataSource())
        .getRound('stage_1', 5);
    expect(bossRound.isBoss, isTrue);
  });

  test(
    'returns a recoverable error when a stage references a missing enemy',
    () async {
      final repository = CampaignRepository(
        _FakeCampaignContentDataSource([_stage(enemyId: 'missing_enemy')]),
      );

      await expectLater(
        repository.getStages(),
        throwsA(isA<CampaignContentException>()),
      );
    },
  );

  test(
    'returns a recoverable error for a round without a spawn marker',
    () async {
      final repository = CampaignRepository(
        _FakeCampaignContentDataSource([_stage(spawnMarker: '')]),
      );

      await expectLater(
        repository.getStages(),
        throwsA(isA<CampaignContentException>()),
      );
    },
  );

  test(
    'rejects map and enemy references outside the local asset registries',
    () async {
      final unknownMapRepository = CampaignRepository(
        _FakeCampaignContentDataSource([_stage(mapKey: 'missing_map')]),
      );
      final unknownSpriteRepository = CampaignRepository(
        _FakeCampaignContentDataSource([
          _stage(enemyFilename: 'missing_sprite'),
        ]),
      );

      await expectLater(
        unknownMapRepository.getStages(),
        throwsA(isA<CampaignContentException>()),
      );
      await expectLater(
        unknownSpriteRepository.getStages(),
        throwsA(isA<CampaignContentException>()),
      );
    },
  );

  test('fails lookup for an unknown stage or round', () async {
    final repository = CampaignRepository(
      _FakeCampaignContentDataSource([_stage()]),
    );

    await expectLater(
      repository.getStage('missing'),
      throwsA(isA<CampaignContentException>()),
    );
    await expectLater(
      repository.getRound('stage_1', 2),
      throwsA(isA<CampaignContentException>()),
    );
  });
}

class _FakeCampaignContentDataSource implements CampaignContentDataSource {
  const _FakeCampaignContentDataSource(this.stages);

  final List<CampaignStageModel> stages;

  @override
  Future<List<CampaignStageModel>> loadStages() async => stages;
}

CampaignStageModel _stage({
  String enemyId = 'blue_torch_guard',
  String enemyFilename = 'torch_blue',
  String mapKey = 'forest',
  String spawnMarker = 'torch_blue',
}) => CampaignStageModel(
  id: 'stage_1',
  order: 1,
  name: 'Forest Outskirts',
  mapKey: mapKey,
  enemies: [
    MonsterModel(
      id: 'blue_torch_guard',
      name: 'Torch Guard',
      filename: enemyFilename,
      hp: 3,
    ),
  ],
  rounds: [
    StageRoundModel(
      id: 'stage_1_round_1',
      number: 1,
      encounters: [
        StageEncounterModel(enemyId: enemyId, spawnMarker: spawnMarker),
      ],
    ),
  ],
);
