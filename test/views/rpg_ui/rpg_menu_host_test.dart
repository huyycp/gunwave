import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/data/data_sources/remote/user_remote_data_source.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/repositories/campaign_progress_repository.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/repositories/user_repository.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/views/game/game_view.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_game.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Campaign menu host renders its screen through Flame', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferences = _MemoryPreferences();
    final progressRepository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(preferences: preferences),
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
    final container = ProviderContainer(
      overrides: [
        appLocaleControllerProvider.overrideWith(
          (ref) => AppLocaleController(preferences: preferences),
        ),
        campaignProgressRepositoryProvider.overrideWithValue(
          progressRepository,
        ),
        campaignRepositoryProvider.overrideWithValue(
          CampaignRepository(_StaticCampaignContentDataSource()),
        ),
        userRepoProvider.overrideWithValue(
          UserRepository(_EmptyUserRemoteDataSource()),
        ),
      ],
    );
    addTearDown(container.dispose);
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

  testWidgets('Solo Hub has a local starter hero without a signed-in user', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferences = _MemoryPreferences();
    final progressRepository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(preferences: preferences),
    );
    final container = ProviderContainer(
      overrides: [
        appLocaleControllerProvider.overrideWith(
          (ref) => AppLocaleController(preferences: preferences),
        ),
        campaignProgressRepositoryProvider.overrideWithValue(
          progressRepository,
        ),
        campaignRepositoryProvider.overrideWithValue(
          CampaignRepository(_StaticCampaignContentDataSource()),
        ),
        userRepoProvider.overrideWithValue(
          UserRepository(_EmptyUserRemoteDataSource()),
        ),
      ],
    );
    addTearDown(container.dispose);
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
    expect(game.snapshot.isAccountSignedIn, isFalse);
    expect(game.snapshot.ownedHeroes, hasLength(1));
    expect(game.snapshot.selectedHero?.id, 'local_starter_warrior_blue');
    expect(game.snapshot.shopHeroes, hasLength(1));

    game.actions.onSelectHero(0);
    await tester.pump();
    await tester.pump();
    game = tester
        .widget<GameWidget<RpgMenuGame>>(find.byType(GameWidget<RpgMenuGame>))
        .game!;
    expect(game.snapshot.ownedHeroes, hasLength(1));
    expect(game.snapshot.selectedHero?.id, 'local_starter_warrior_blue');
  });

  testWidgets('Selected input mode is used when launching a campaign stage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final preferences = _MemoryPreferences();
    final progressRepository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(preferences: preferences),
    );
    final container = ProviderContainer(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeProvider.instance),
        appLocaleControllerProvider.overrideWith(
          (ref) => AppLocaleController(preferences: preferences),
        ),
        campaignProgressRepositoryProvider.overrideWithValue(
          progressRepository,
        ),
      ],
    );
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

class _MemoryPreferences implements SharedPreferencesAsync {
  final Map<String, Object> values = {};

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyUserRemoteDataSource implements UserRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StaticCampaignContentDataSource implements CampaignContentDataSource {
  @override
  Future<List<CampaignStageModel>> loadStages() async => [testCampaignStage()];
}
