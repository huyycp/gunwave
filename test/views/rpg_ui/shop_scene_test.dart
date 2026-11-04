import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

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
}
