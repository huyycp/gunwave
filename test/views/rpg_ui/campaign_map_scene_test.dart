import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flame/text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/campaign_map_scene.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame(
    'Campaign Map keeps stage nodes visible and prevents locked-stage selection',
    () => testRpgMenuGame(
      initialPage: RpgMenuPage.campaignMap,
      snapshot: testRpgMenuSnapshot(
        stages: [
          testCampaignStage(),
          testCampaignStage().copyWith(
            id: 'stage_2',
            order: 2,
            unlockRequirementStageId: 'stage_1',
          ),
        ],
      ),
    ),
    (game) async {
      await game.ready();
      final map = activeRpgMenuScene(game) as CampaignMapScene;
      expect(map.children.whereType<SpriteComponent>(), hasLength(2));
      final buttons = map.children.whereType<AssetButtonComponent>().toList();
      expect(buttons, hasLength(3));
      expect(buttons[1].label, '1');
      expect(buttons[1].enabled, isTrue);
      expect(buttons[2].label, '2');
      expect(buttons[2].enabled, isFalse);
      final statusLabels = map.children
          .whereType<TextComponent<SpriteFontRenderer>>()
          .map((component) => component.text);
      expect(statusLabels, contains('Available'));
      expect(statusLabels, contains('Locked'));

      game.onGameResize(Vector2(720, 405));
      final stageNode = buttons[1];
      expect(
        stageNode.position.x - stageNode.width / 2,
        greaterThanOrEqualTo(0),
      );
      expect(
        stageNode.position.x + stageNode.width / 2,
        lessThanOrEqualTo(720),
      );
      expect(
        stageNode.width,
        greaterThanOrEqualTo(GameHudStyle.minimumTouchSize),
      );
    },
  );
}
