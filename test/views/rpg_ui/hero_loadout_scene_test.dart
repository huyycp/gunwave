import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var selectedHeroIndex = -1;
  var launchedHeroId = '';

  testWithGame(
    'Hero Loadout forwards hero selection and stage launch',
    () {
      return testRpgMenuGame(
        initialPage: RpgMenuPage.heroLoadout,
        snapshot: testRpgMenuSnapshot(
          ownedHeroes: [
            testHero(),
            testHero(id: 'hero_red'),
          ],
        ),
        actions: testRpgMenuActions(
          onSelectHero: (index) => selectedHeroIndex = index,
          onLaunchStage: (_, hero) => launchedHeroId = hero.id,
        ),
      );
    },
    (game) async {
      await game.ready();
      expect(
        activeRpgMenuScene(game).children.whereType<SpriteAnimationComponent>(),
        hasLength(1),
      );
      final buttons = activeRpgMenuScene(game).children
          .whereType<AssetButtonComponent>()
          .toList();
      final nextHero = buttons[5];
      _tap(nextHero, game);
      expect(selectedHeroIndex, 1);
      final launchButton = buttons.last;
      expect(launchButton.enabled, isTrue);
      _tap(launchButton, game);
      expect(launchedHeroId, 'hero_blue');
    },
  );
}

void _tap(AssetButtonComponent button, FlameGame game) {
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
