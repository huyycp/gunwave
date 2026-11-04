import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/game/ui/components/asset_progress_bar_component.dart';
import 'package:gunwave/views/game/ui/components/combat_hud_component.dart';

import 'campaign_ui_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('HUD updates player, round, boss, and ability snapshots', (
    game,
  ) async {
    final labels = testCampaignUiLabels();
    var pauses = 0;
    var abilityActivations = 0;
    final hud = await CombatHudComponent.load(
      game.images,
      labels: labels,
      safeAreaInsets: EdgeInsets.zero,
      showAbility: true,
      showKeyboardGuide: false,
      onPause: () => pauses++,
      onActivateAbility: () => abilityActivations++,
    );
    await game.ensureAdd(hud);

    hud.updateSnapshot(
      const CombatHudSnapshot(
        playerHealth: 60,
        playerMaxHealth: 100,
        round: 5,
        roundCount: 5,
        abilityAvailable: false,
        abilityStatus: 'Ready in 3s',
        bossHealth: 12,
        bossMaxHealth: 24,
      ),
    );

    expect(hud.snapshot?.round, 5);
    expect(hud.snapshot?.playerHealth, 60);
    final bars = hud.children.whereType<AssetProgressBarComponent>().toList();
    expect(bars, hasLength(2));
    expect(bars.first.value, 0.6);
    expect(bars.last.value, 0.5);
    final panels = hud.children.whereType<AssetPanelComponent>().toList();
    expect(panels[2].isVisible, isTrue);

    hud.showNotice('Gesture input unavailable');
    expect(panels[3].isVisible, isTrue);
    hud.update(4);
    expect(panels[3].isVisible, isFalse);

    final buttons = hud.children.whereType<AssetButtonComponent>().toList();
    final pause = buttons.first;
    final ability = buttons.last;
    expect(ability.enabled, isFalse);
    pause.onTapDown(
      TapDownEvent(1, game, TapDownDetails(globalPosition: Offset.zero)),
    );
    pause.onTapUp(
      TapUpEvent(
        1,
        game,
        TapUpDetails(
          globalPosition: Offset.zero,
          kind: PointerDeviceKind.touch,
        ),
      ),
    );
    ability.enabled = true;
    ability.onTapDown(
      TapDownEvent(2, game, TapDownDetails(globalPosition: Offset.zero)),
    );
    ability.onTapUp(
      TapUpEvent(
        2,
        game,
        TapUpDetails(
          globalPosition: Offset.zero,
          kind: PointerDeviceKind.touch,
        ),
      ),
    );
    expect(pauses, 1);
    expect(abilityActivations, 1);
  });
}
