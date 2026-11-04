import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/game/ui/components/pause_menu_component.dart';

import 'campaign_ui_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('pause menu resumes or confirms leaving the stage', (
    game,
  ) async {
    var resumes = 0;
    var exits = 0;
    const insets = EdgeInsets.fromLTRB(40, 20, 24, 18);
    final menu = await PauseMenuComponent.load(
      game.images,
      labels: testCampaignUiLabels(),
      safeAreaInsets: insets,
      onResume: () => resumes++,
      onExitConfirmed: () => exits++,
    );
    await game.ensureAdd(menu);
    menu.onGameResize(Vector2(640, 360));
    final panel = menu.children.whereType<AssetPanelComponent>().single;
    expect(panel.x, greaterThanOrEqualTo(insets.left));
    expect(panel.x + panel.width, lessThanOrEqualTo(640 - insets.right));

    final buttons = menu.children.whereType<AssetButtonComponent>().toList();
    expect(buttons, hasLength(2));
    for (var index = 0; index < buttons.length; index++) {
      final button = buttons[index];
      button.onTapDown(
        TapDownEvent(
          index + 1,
          game,
          TapDownDetails(globalPosition: Offset.zero),
        ),
      );
      button.onTapUp(
        TapUpEvent(
          index + 1,
          game,
          TapUpDetails(
            globalPosition: Offset.zero,
            kind: PointerDeviceKind.touch,
          ),
        ),
      );
    }

    expect(resumes, 1);
    expect(exits, 1);
  });
}
