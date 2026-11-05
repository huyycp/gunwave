import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_hero_catalog.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/views/rpg_ui/scenes/shop_scene.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var purchases = 0;

  testWithGame(
    'Shop disables unaffordable purchases and forwards affordable ones',
    () {
      return testRpgMenuGame(
        initialPage: RpgMenuPage.shop,
        snapshot: testRpgMenuSnapshot(
          ownedHeroes: [testHero()],
          shopHeroes: [
            testHero(id: 'hero_affordable'),
            testHero(id: 'hero_costly').copyWith(price: 500),
          ],
          gold: 100,
        ),
        actions: testRpgMenuActions(
          onPurchase: (_) async {
            purchases++;
          },
        ),
      );
    },
    (game) async {
      await game.ready();
      final buttons = activeRpgMenuScene(game).children
          .whereType<AssetButtonComponent>()
          .toList();
      final text = activeRpgMenuScene(game).children
          .whereType<TextComponent<SpriteFontRenderer>>()
          .map((component) => component.text);
      expect(buttons, hasLength(3));
      expect(text, contains('Gold: 100'));
      expect(buttons[1].enabled, isTrue);
      expect(buttons[2].enabled, isFalse);
      final scene = activeRpgMenuScene(game) as ShopScene;
      final panel = scene.children.whereType<AssetPanelComponent>().first;
      game.onGameResize(Vector2(640, 360));
      expect(panel.width, lessThan(640 * 0.9));
      expect(panel.height, lessThan(360 * 0.9));
      buttons[1].onTapDown(
        TapDownEvent(1, game, TapDownDetails(globalPosition: Offset.zero)),
      );
      buttons[1].onTapUp(
        TapUpEvent(
          1,
          game,
          TapUpDetails(
            globalPosition: Offset.zero,
            kind: PointerDeviceKind.touch,
          ),
        ),
      );
      expect(purchases, 1);
    },
  );

  testWithGame(
    'Shop explains account and catalog empty states',
    () => testRpgMenuGame(
      initialPage: RpgMenuPage.shop,
      snapshot: testRpgMenuSnapshot(
        shopHeroes: const [],
        isAccountSignedIn: false,
      ),
    ),
    (game) async {
      await game.ready();
      final scene = activeRpgMenuScene(game) as ShopScene;
      final labels = scene.children
          .whereType<TextComponent<SpriteFontRenderer>>()
          .map((component) => component.text);
      expect(labels, contains('Sign in to buy more heroes'));
      expect(scene.children.whereType<AssetButtonComponent>(), hasLength(1));
    },
  );

  testWithGame(
    'Shop previews the local starter hero for solo play',
    () => testRpgMenuGame(
      initialPage: RpgMenuPage.shop,
      snapshot: testRpgMenuSnapshot(
        ownedHeroes: [CampaignHeroCatalog.starter],
        shopHeroes: [CampaignHeroCatalog.starter],
        isAccountSignedIn: false,
      ),
    ),
    (game) async {
      await game.ready();
      final scene = activeRpgMenuScene(game) as ShopScene;
      expect(
        scene.children.whereType<SpriteAnimationComponent>(),
        hasLength(1),
      );
      final starterButton = scene.children
          .whereType<AssetButtonComponent>()
          .singleWhere((button) => button.label == 'Owned');
      expect(starterButton.enabled, isFalse);
      expect(
        scene.children.whereType<TextComponent<SpriteFontRenderer>>().map(
          (component) => component.text,
        ),
        contains('Sign in to buy more heroes'),
      );

      game.onGameResize(Vector2(640, 360));
      final cardPanel = scene.children.whereType<AssetPanelComponent>().last;
      final preview = scene.children
          .whereType<SpriteAnimationComponent>()
          .single;
      final purchaseButton = scene.children
          .whereType<AssetButtonComponent>()
          .singleWhere((button) => button.label == 'Owned');
      expect(
        preview.position.y + preview.height / 2,
        lessThan(purchaseButton.position.y - purchaseButton.height / 2),
      );
      expect(
        purchaseButton.position.x - purchaseButton.width / 2,
        greaterThanOrEqualTo(cardPanel.position.x),
      );
      expect(
        purchaseButton.position.x + purchaseButton.width / 2,
        lessThanOrEqualTo(cardPanel.position.x + cardPanel.width),
      );
    },
  );
}
