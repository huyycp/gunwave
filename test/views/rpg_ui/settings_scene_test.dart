import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

import 'rpg_menu_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var selectedMode = AppLocaleMode.system;

  testWithGame(
    'Settings exposes system, English, and Vietnamese locale choices',
    () {
      return testRpgMenuGame(
        initialPage: RpgMenuPage.settings,
        actions: testRpgMenuActions(
          onSelectLocale: (mode) => selectedMode = mode,
        ),
      );
    },
    (game) async {
      await game.ready();
      final buttons = activeRpgMenuScene(game).children
          .whereType<AssetButtonComponent>()
          .toList();
      expect(buttons, hasLength(4));
      expect(buttons[1].enabled, isFalse);
      expect(buttons[2].label, 'English');
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
    },
  );
}
