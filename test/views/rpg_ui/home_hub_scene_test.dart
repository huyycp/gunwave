import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_game.dart';
import 'package:gunwave/views/rpg_ui/scenes/home_hub_scene.dart';
import 'package:gunwave/views/rpg_ui/scenes/campaign_map_scene.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame(
    'Home Hub renders its primary actions and routes to the campaign map',
    () => testRpgMenuGame(
      initialPage: RpgMenuPage.homeHub,
      snapshot: testRpgMenuSnapshot(
        campaignGold: 100,
        campaignStatusPoints: 25,
      ),
    ),
    (game) async {
      await game.ready();
      expect(game.router.currentRoute.name, RpgMenuPage.homeHub.routeName);
      final hub = activeRpgMenuScene(game) as HomeHubScene;
      final buttons = hub.children.whereType<AssetButtonComponent>();
      final labels = hub.children
          .whereType<TextComponent<SpriteFontRenderer>>()
          .map((component) => component.text);
      expect(buttons.map((button) => button.label), contains('Continue'));
      expect(buttons.map((button) => button.label), contains('Hero Loadout'));
      expect(buttons.map((button) => button.label), contains('Shop'));
      expect(labels, contains('100'));
      expect(labels, contains('25'));
      expect(hub.children.whereType<SpriteAnimationComponent>(), hasLength(1));

      game.onGameResize(Vector2(640, 360));
      final actionButtons =
          [
            for (final label in ['Continue', 'Hero Loadout', 'Shop'])
              buttons.singleWhere((button) => button.label == label),
          ]..sort(
            (first, second) => (first.position.x - first.width / 2).compareTo(
              second.position.x - second.width / 2,
            ),
          );
      expectRpgMenuLayoutWithinViewport(hub, Vector2(640, 360));
      for (final button in actionButtons) {
        expect(button.position.x - button.width / 2, greaterThanOrEqualTo(0));
        expect(button.position.x + button.width / 2, lessThanOrEqualTo(640));
        expect(button.position.y, lessThanOrEqualTo(360));
        expect(button.position.y - button.height, greaterThanOrEqualTo(0));
      }
      final panels = hub.children.whereType<AssetPanelComponent>().toList();
      expect(panels, hasLength(2));
      expect(panels.every((panel) => panel.height <= 360 * 0.6), isTrue);
      expect(panels.every((panel) => panel.height >= 360 * 0.55), isTrue);
      expect(
        panels.fold<double>(0, (sum, panel) => sum + panel.width),
        greaterThan(640 * 0.84),
      );
      expect(
        panels.fold<double>(0, (sum, panel) => sum + panel.width),
        lessThan(640 * 0.96),
      );
      for (var index = 1; index < actionButtons.length; index++) {
        final previous = actionButtons[index - 1];
        final current = actionButtons[index];
        expect(
          current.position.x - current.width / 2,
          greaterThan(previous.position.x + previous.width / 2),
        );
      }

      game.navigate(RpgMenuPage.heroLoadout);
      await game.ready();
      final loadoutBack = activeRpgMenuScene(game).children
          .whereType<AssetButtonComponent>()
          .singleWhere((button) => button.label == 'Back');
      _tap(loadoutBack, game);
      await game.ready();
      expect(game.router.currentRoute.name, RpgMenuPage.homeHub.routeName);

      game.navigate(RpgMenuPage.campaignMap);
      await game.ready();
      expect(game.router.currentRoute.name, RpgMenuPage.campaignMap.routeName);
      expect(activeRpgMenuScene(game), isA<CampaignMapScene>());
    },
  );
}

void _tap(AssetButtonComponent button, RpgMenuGame game) {
  button.onTapDown(
    TapDownEvent(1, game, TapDownDetails(globalPosition: Offset.zero)),
  );
  button.onTapUp(
    TapUpEvent(
      1,
      game,
      TapUpDetails(globalPosition: Offset.zero, kind: PointerDeviceKind.touch),
    ),
  );
}
