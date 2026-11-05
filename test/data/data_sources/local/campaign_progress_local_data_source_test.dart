import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/data_sources/local/local_game_data_seeder.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/data/data_sources/local/database_campaign_content_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late CampaignProgressLocalDataSource dataSource;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await LocalGameDataSeeder(
      database,
      contentDataSource: AssetCampaignContentDataSource(),
    ).seed();
    dataSource = CampaignProgressLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'starts with empty progress, zero balances, and the starter selected',
    () async {
      final progress = await dataSource.load();

      expect(progress.completedStageIds, isEmpty);
      expect(progress.selectedHeroId, CampaignHeroCatalog.starter.id);
      expect(progress.goldBalance, 0);
      expect(progress.statusPointBalance, 0);
    },
  );

  test('clears a stage and updates local balances atomically', () async {
    final stage = await CampaignRepository(
      DriftCampaignContentDataSource(database),
    ).getStage('stage_1');

    final result = await dataSource.completeStage(stage);
    final restored = await dataSource.load();

    expect(result.wasFirstCompletion, isTrue);
    expect(restored.completedStageIds, {'stage_1'});
    expect(restored.goldBalance, 100);
    expect(restored.statusPointBalance, 25);
    expect(
      (await database.select(database.playerStates).getSingle()).gold,
      100,
    );
    expect(
      await database.select(database.campaignStageClears).get(),
      hasLength(1),
    );
  });

  test('repeated stage clear does not issue the reward twice', () async {
    final stage = await CampaignRepository(
      DriftCampaignContentDataSource(database),
    ).getStage('stage_1');
    await dataSource.completeStage(stage);

    final replay = await dataSource.completeStage(stage);
    final restored = await dataSource.load();

    expect(replay.wasFirstCompletion, isFalse);
    expect(restored.goldBalance, 100);
    expect(restored.statusPointBalance, 25);
  });

  test('only an owned hero can become the selected hero', () async {
    await expectLater(
      dataSource.selectHero('missing_hero'),
      throwsArgumentError,
    );

    final selected = await dataSource.selectHero(
      CampaignHeroCatalog.starter.id,
    );
    expect(selected.selectedHeroId, CampaignHeroCatalog.starter.id);
  });
}
