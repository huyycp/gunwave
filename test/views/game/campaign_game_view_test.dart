import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/repositories/campaign_repository.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/views/game/game_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('campaign game is hosted by Flame without Flutter game UI', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final stage = await CampaignRepository(AssetCampaignContentDataSource())
        .getStage('stage_1');
    final container = ProviderContainer(
      overrides: [themeProvider.overrideWith((ref) => ThemeProvider())],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameView(
            campaignStage: stage,
            character: const CharacterModel(
              filename: 'warrior_blue',
              hp: 100,
              str: 10,
              agi: 100,
            ),
            playMode: GamePlayMode.joystick,
            onCampaignStageCompleted: (_) async => CampaignStageCompletion(
              progress: CampaignProgressModel(),
              wasFirstCompletion: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GameView), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
