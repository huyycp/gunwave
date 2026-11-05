import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/data_sources/local/database_campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/local_game_data_seeder.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';
import 'package:gunwave/repositories/campaign_progress_repository.dart';
import 'package:gunwave/repositories/campaign_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late CampaignProgressRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await LocalGameDataSeeder(
      database,
      contentDataSource: AssetCampaignContentDataSource(),
    ).seed();
    repository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('first completion grants all rewards and stores one clear', () async {
    final stage = await CampaignRepository(
      DriftCampaignContentDataSource(database),
    ).getStage('stage_1');
    final completion = await repository.completeStage(stage);

    expect(completion.wasFirstCompletion, isTrue);
    expect(completion.progress.completedStageIds, {'stage_1'});
    expect(completion.progress.goldBalance, 100);
    expect(completion.progress.statusPointBalance, 25);
    final restored = await repository.getProgress();
    expect(restored.completedStageIds, completion.progress.completedStageIds);
    expect(restored.goldBalance, completion.progress.goldBalance);
    expect(restored.statusPointBalance, completion.progress.statusPointBalance);
  });

  test(
    'replays and concurrent completion attempts grant rewards once',
    () async {
      final stage = await CampaignRepository(
        DriftCampaignContentDataSource(database),
      ).getStage('stage_1');
      final completions = await Future.wait([
        repository.completeStage(stage),
        repository.completeStage(stage),
      ]);
      final replay = await repository.completeStage(stage);
      final restored = await repository.getProgress();

      expect(
        completions.where((result) => result.wasFirstCompletion),
        hasLength(1),
      );
      expect(replay.wasFirstCompletion, isFalse);
      expect(restored.completedStageIds, {'stage_1'});
      expect(restored.goldBalance, 100);
      expect(restored.statusPointBalance, 25);
      expect(
        (await database.select(database.playerStates).getSingle()).gold,
        100,
      );
    },
  );

  test('selected hero persists through repository recreation', () async {
    repository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(database),
    );
    await repository.selectHero('local_starter_warrior_blue');
    repository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(database),
    );

    expect(
      (await repository.getProgress()).selectedHeroId,
      'local_starter_warrior_blue',
    );
  });

  test('rejects unknown and negative rewards before database writes', () async {
    expect(
      () => repository.completeStage(
        _stage(
          rewards: const [RewardModel(type: RewardType.unknown, amount: 4)],
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => repository.completeStage(
        _stage(rewards: const [RewardModel(type: RewardType.gold, amount: -1)]),
      ),
      throwsArgumentError,
    );
    expect((await repository.getProgress()).completedStageIds, isEmpty);
    expect(await repository.getProgress().then((p) => p.goldBalance), 0);
  });
}

CampaignStageModel _stage({required List<RewardModel> rewards}) =>
    CampaignStageModel(
      id: 'stage_1',
      order: 1,
      name: 'Forest Outskirts',
      mapKey: 'forest',
      enemies: const [
        MonsterModel(id: 'enemy', name: 'Enemy', filename: 'torch_blue', hp: 1),
      ],
      rounds: const [
        StageRoundModel(
          id: 'stage_1_round_1',
          number: 1,
          encounters: [
            StageEncounterModel(enemyId: 'enemy', spawnMarker: 'torch_blue'),
          ],
        ),
      ],
      rewards: rewards,
    );
