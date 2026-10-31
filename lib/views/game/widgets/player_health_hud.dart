import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

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
      return Semantics(
        label: context.l10n.healthPoints,
        value: '$current / $maxHealth',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GameHudStyle.gap),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LinearProgressIndicator(
                value: maxHealth > 0 ? current / maxHealth : 0,
                minHeight: GameHudStyle.healthHeight,
                backgroundColor: GameHudStyle.healthBackground,
                color: GameHudStyle.healthFill,
              ),
              Text(
                '$current / $maxHealth',
                style: const TextStyle(
                  color: GameHudStyle.foreground,
                  fontSize: GameHudStyle.labelFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
