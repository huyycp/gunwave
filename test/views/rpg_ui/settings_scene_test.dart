import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var selectedMode = AppLocaleMode.system;
  var selectedPlayMode = GamePlayMode.joystick;

  testWithGame(
    'Settings exposes system, English, and Vietnamese locale choices',
    () {
      return testRpgMenuGame(
        initialPage: RpgMenuPage.settings,
        actions: testRpgMenuActions(
          onSelectLocale: (mode) => selectedMode = mode,
          onSelectPlayMode: (mode) => selectedPlayMode = mode,
        ),
      );
    },
    (game) async {
      await game.ready();
      final buttons = activeRpgMenuScene(game).children
          .whereType<AssetButtonComponent>()
          .toList();
      expect(buttons, hasLength(7));
      expect(buttons[1].enabled, isFalse);
      expect(buttons[2].label, 'English');
      expect(buttons[4].label, '[x] Joystick');
      expect(buttons[4].enabled, isTrue);
      expect(buttons[5].label, 'Keyboard');
      buttons[2].onTapDown(
        TapDownEvent(1, game, TapDownDetails(globalPosition: Offset.zero)),
      );
      buttons[2].onTapUp(
        TapUpEvent(
          1,
          game,
          TapUpDetails(
            globalPosition: Offset.zero,
            kind: PointerDeviceKind.touch,
          ),
        ),
      );
      expect(selectedMode, AppLocaleMode.english);

      buttons[5].onTapDown(
        TapDownEvent(2, game, TapDownDetails(globalPosition: Offset.zero)),
      );
      buttons[5].onTapUp(
        TapUpEvent(
          2,
          game,
          TapUpDetails(
            globalPosition: Offset.zero,
            kind: PointerDeviceKind.touch,
          ),
        ),
      );
      expect(selectedPlayMode, GamePlayMode.keyboard);
    },
  );

  testWithGame(
    'Settings marks the selected control mode in the asset label',
    () => testRpgMenuGame(
      initialPage: RpgMenuPage.settings,
      snapshot: testRpgMenuSnapshot(selectedPlayMode: GamePlayMode.keyboard),
    ),
    (game) async {
      await game.ready();
      final buttons = activeRpgMenuScene(game).children
          .whereType<AssetButtonComponent>()
          .toList();
      expect(buttons[5].label, '[x] Keyboard');
      expect(buttons[4].label, 'Joystick');
      expect(buttons[6].label, 'Gesture');
    },
  );

  testWithGame(
    'Settings keeps all choices inside compact and wide landscape bounds',
    () => testRpgMenuGame(initialPage: RpgMenuPage.settings),
    (game) async {
      await game.ready();
      for (final viewport in [Vector2(640, 360), Vector2(1920, 1080)]) {
        game.onGameResize(viewport);
        final scene = activeRpgMenuScene(game);
        final bounds = scene.responsiveLayout.contentBounds;
        for (final button in scene.children.whereType<AssetButtonComponent>()) {
          final left = button.position.x - button.width / 2;
          final top = button.position.y - button.height / 2;
          expect(left, greaterThanOrEqualTo(bounds.left));
          expect(top, greaterThanOrEqualTo(bounds.top));
          expect(left + button.width, lessThanOrEqualTo(bounds.right));
          expect(top + button.height, lessThanOrEqualTo(bounds.bottom));
        }
      }
    },
  );
}
