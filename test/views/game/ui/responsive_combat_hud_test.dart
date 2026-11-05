import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/game/ui/components/combat_hud_component.dart';

import 'campaign_ui_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('HUD respects safe insets and responsive screen widths', (
    game,
  ) async {
    final hud = await CombatHudComponent.load(
      game.images,
      labels: testCampaignUiLabels(),
      safeAreaInsets: const EdgeInsets.fromLTRB(24, 12, 20, 14),
      showAbility: true,
      showKeyboardGuide: false,
      onPause: () {},
      onActivateAbility: () {},
    );
    await game.ensureAdd(hud);

    double? previousAbilityLabelScale;
    for (final size in [
      Vector2(360, 320),
      Vector2(640, 360),
      Vector2(1280, 720),
      Vector2(1920, 1080),
    ]) {
      hud.onGameResize(size);
      final healthPanel = hud.children.whereType<AssetPanelComponent>().first;
      final roundPanel = hud.children
          .whereType<AssetPanelComponent>()
          .elementAt(1);
      final abilityButton = hud.children.whereType<AssetButtonComponent>().last;
      final abilityLabel = abilityButton.children
          .whereType<TextComponent<SpriteFontRenderer>>()
          .single;
      expect(healthPanel.x, greaterThanOrEqualTo(24));
      expect(healthPanel.y, greaterThanOrEqualTo(12));
      expect(
        healthPanel.x + healthPanel.width,
        lessThanOrEqualTo(roundPanel.x),
      );
      expect(
        abilityButton.x + abilityButton.width,
        lessThanOrEqualTo(size.x - 20),
      );
      expect(
        abilityButton.containsLocalPoint(
          Vector2(abilityButton.width / 2, abilityButton.height / 2),
        ),
        isTrue,
      );
      expect(
        abilityLabel.scale.x,
        closeTo(
          AppTypography.bitmapScale(
            abilityButton.labelFontSize,
            responsiveScale: abilityButton.responsiveTextScale,
          ),
          0.001,
        ),
      );
      if (previousAbilityLabelScale != null) {
        expect(
          abilityLabel.scale.x,
          greaterThanOrEqualTo(previousAbilityLabelScale),
        );
      }
      previousAbilityLabelScale = abilityLabel.scale.x;
    }
  });
}
