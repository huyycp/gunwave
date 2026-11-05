import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame/text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/stage_briefing_scene.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame(
    'Stage Briefing shows five distinct round markers and a boss finale',
    () => testRpgMenuGame(initialPage: RpgMenuPage.stageBriefing),
    (game) async {
      await game.ready();
      final briefing = activeRpgMenuScene(game) as StageBriefingScene;
      final buttons = briefing.children
          .whereType<AssetButtonComponent>()
          .toList();
      expect(buttons, hasLength(7));
      expect(buttons.take(5).map((button) => button.label), [
        '1',
        '2',
        '3',
        '4',
        '5',
      ]);
      expect(buttons.last.enabled, isTrue);
      final text = briefing.children
          .whereType<TextComponent<SpriteFontRenderer>>()
          .map((component) => component.text);
      expect(text, contains('Gold: 100'));
      expect(text, contains('Boss: Elder Torch'));
      for (final viewport in [
        Vector2(640, 360),
        Vector2(1280, 720),
        Vector2(1920, 1080),
      ]) {
        game.onGameResize(viewport);
        for (final marker in buttons.take(5)) {
          expect(marker.position.x - marker.width / 2, greaterThanOrEqualTo(0));
          expect(
            marker.position.x + marker.width / 2,
            lessThanOrEqualTo(viewport.x),
          );
          expect(
            marker.position.y - marker.height / 2,
            greaterThanOrEqualTo(0),
          );
          expect(
            marker.position.y + marker.height / 2,
            lessThanOrEqualTo(viewport.y),
          );
        }
      }
    },
  );

  testWithGame(
    'Stage Briefing uses the barrel idle cell at its native frame size',
    () => testRpgMenuGame(
      initialPage: RpgMenuPage.stageBriefing,
      snapshot: testRpgMenuSnapshot(stages: [_testBarrelStage()]),
    ),
    (game) async {
      await game.ready();
      final briefing = activeRpgMenuScene(game) as StageBriefingScene;
      final preview = briefing.children
          .whereType<SpriteAnimationComponent>()
          .single;
      final frame = preview.animation!.frames.single.sprite;

      expect(frame.srcPosition, Vector2(0, 256));
      expect(frame.srcSize, Vector2.all(128));
    },
  );
}

CampaignStageModel _testBarrelStage() {
  final stage = testCampaignStage();
  return stage.copyWith(
    enemies: [stage.enemies.single.copyWith(filename: 'barrel_blue')],
  );
}
