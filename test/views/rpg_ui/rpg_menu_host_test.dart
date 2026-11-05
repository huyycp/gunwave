import 'package:drift/native.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/character_catalog_data_source.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/data_sources/local/local_game_data_seeder.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/repositories/campaign_progress_repository.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/repositories/character_repository.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_game.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<CampaignStageModel> bundledStages;
  late CharacterCatalogContent characterCatalog;

  setUpAll(() async {
    bundledStages = await AssetCampaignContentDataSource().loadStages();
    characterCatalog = await AssetCharacterCatalogDataSource().loadCatalog();
  });

  Future<AppDatabase> createDatabase() async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await LocalGameDataSeeder(
      database,
      contentDataSource: _StaticCampaignContentDataSource(bundledStages),
      characterCatalogDataSource: _StaticCharacterCatalogDataSource(
        characterCatalog,
      ),
    ).seed();
    return database;
  }

  List<Override> appOverrides(AppDatabase database) => [
    appDatabaseProvider.overrideWithValue(database),
    themeProvider.overrideWith((ref) => ThemeProvider.forTesting()),
    appLocaleControllerProvider.overrideWith(
      (ref) => AppLocaleController(database),
    ),
  ];

  testWidgets('Campaign menu host renders database progress through Flame', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = await createDatabase();
    addTearDown(database.close);
    final progressRepository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(database),
    );
    await progressRepository.completeStage(
      const CampaignStageModel(
        id: 'stage_1',
        rewards: [
          RewardModel(type: RewardType.gold, amount: 100),
          RewardModel(type: RewardType.sp, amount: 25),
        ],
      ),
    );
    expect(
      (await progressRepository.getProgress()).completedStageIds,
      contains('stage_1'),
    );
    final container = ProviderContainer(overrides: appOverrides(database));
    addTearDown(container.dispose);
    expect(
      await container.read(campaignRepositoryProvider).getStages(),
      isNotEmpty,
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RpgMenuHost(initialPage: RpgMenuPage.campaignMap),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(GameWidget<RpgMenuGame>), findsOneWidget);
    expect(find.byType(Text), findsNothing);
    final game = tester
        .widget<GameWidget<RpgMenuGame>>(find.byType(GameWidget<RpgMenuGame>))
        .game!;
    expect(game.snapshot.clearedStageIds, {'stage_1'});
    expect(game.snapshot.campaignGold, 100);
    expect(game.snapshot.campaignStatusPoints, 25);
  });

  testWidgets('local Hub loads the seeded starter and campaign', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = await createDatabase();
    addTearDown(database.close);
    final container = ProviderContainer(overrides: appOverrides(database));
    addTearDown(container.dispose);
    expect(
      await container.read(campaignRepositoryProvider).getStages(),
      isNotEmpty,
    );
    expect(
      await container.read(characterRepoProvider).getOwnedCharacters(),
      hasLength(1),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RpgMenuHost(initialPage: RpgMenuPage.homeHub),
        ),
      ),
    );
    var game = tester
        .widget<GameWidget<RpgMenuGame>>(find.byType(GameWidget<RpgMenuGame>))
        .game!;
    for (var frame = 0; frame < 20 && game.snapshot.isLoading; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      game = tester
          .widget<GameWidget<RpgMenuGame>>(find.byType(GameWidget<RpgMenuGame>))
          .game!;
    }
    expect(game.snapshot.isLoading, isFalse);
    expect(game.snapshot.ownedHeroes, hasLength(1));
    expect(game.snapshot.selectedHero?.id, CampaignHeroCatalog.starter.id);
    expect(game.snapshot.shopHeroes, hasLength(8));

    game.actions.onSelectHero(0);
    await tester.pump();
    await tester.pump();
    game = tester
        .widget<GameWidget<RpgMenuGame>>(find.byType(GameWidget<RpgMenuGame>))
        .game!;
    expect(game.snapshot.ownedHeroes, hasLength(1));
    expect(game.snapshot.selectedHero?.id, CampaignHeroCatalog.starter.id);
  });

  testWidgets('Selected input mode is used when launching a campaign stage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final database = await createDatabase();
    addTearDown(database.close);
    final container = ProviderContainer(overrides: appOverrides(database));
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RpgMenuHost(initialPage: RpgMenuPage.settings),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    var game = tester
        .widget<GameWidget<RpgMenuGame>>(find.byType(GameWidget<RpgMenuGame>))
        .game!;
    game.actions.onSelectPlayMode(GamePlayMode.keyboard);
    await tester.pump();

    game = tester
        .widget<GameWidget<RpgMenuGame>>(find.byType(GameWidget<RpgMenuGame>))
        .game!;
    expect(game.snapshot.selectedPlayMode, GamePlayMode.keyboard);
    game.actions.onLaunchStage(testCampaignStage(), testHero());
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.widget<GameView>(find.byType(GameView)).playMode,
      GamePlayMode.keyboard,
    );
  });
}

class _StaticCampaignContentDataSource implements CampaignContentDataSource {
  const _StaticCampaignContentDataSource(this._stages);

  final List<CampaignStageModel> _stages;

  @override
  Future<List<CampaignStageModel>> loadStages() async => _stages;
}

class _StaticCharacterCatalogDataSource implements CharacterCatalogDataSource {
  const _StaticCharacterCatalogDataSource(this._catalog);

  final CharacterCatalogContent _catalog;

  @override
  Future<CharacterCatalogContent> loadCatalog() async => _catalog;
}
