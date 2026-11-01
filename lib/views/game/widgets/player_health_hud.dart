import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/views/game/components/sub_components/pixel_health_bar_painter.dart';

/// Rebuilds the numeric HP bar only when the character's health changes.
class PlayerHealthHud extends StatelessWidget {
  const PlayerHealthHud({
    required this.health,
    required this.maxHealth,
    super.key,
  });
  final ValueListenable<int> health;
  final int maxHealth;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: health,
    builder: (context, value, _) {
      final current = value.clamp(0, maxHealth > 0 ? maxHealth : 0);
      final ratio = maxHealth > 0 ? current / maxHealth : 0.0;
      return Semantics(
        label: context.l10n.healthPoints,
        value: '$current / $maxHealth',
        child: SizedBox(
          height: GameHudStyle.healthHeight,
          child: CustomPaint(
            painter: PixelHealthBarPainter(ratio: ratio),
            child: Center(
              child: Text(
                '$current / $maxHealth',
                style: const TextStyle(
                  color: GameHudStyle.foreground,
                  fontSize: GameHudStyle.labelFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
