import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/localization/build_context_l10n.dart';
import 'package:gunwave/views/game/abilities/ability_controller.dart';
import 'package:gunwave/views/game/abilities/ability_visual_style.dart';

/// Compact keyboard status beside HP, or a cooldown-only touch button.
class AbilityHud extends StatelessWidget {
  const AbilityHud({
    required this.controller,
    required this.isKeyboard,
    required this.onActivate,
    super.key,
  });
  final AbilityController controller;
  final bool isKeyboard;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final ability = controller.ability;
      if (ability == null) return const SizedBox.shrink();
      final style = AbilityVisualStyle.forKey(ability.definition.key);
      final cooldown = controller.cooldownRemaining.ceil();
      final status = controller.isUsing
          ? context.l10n.abilityInUse
          : cooldown > 0
          ? context.l10n.secondsShort(cooldown)
          : context.l10n.specialAbilityKeyboard;
      final label = isKeyboard
          ? status
          : cooldown > 0
          ? '$cooldown'
          : null;
      return Tooltip(
        message:
            '${ability.definition.name}\n${ability.definition.description}',
        child: Semantics(
          label: context.l10n.specialAbility,
          value: cooldown > 0 ? context.l10n.abilityCooldown(cooldown) : status,
          child: Material(
            color: GameHudStyle.panel,
            borderRadius: BorderRadius.circular(GameHudStyle.gap),
            child: InkWell(
              onTap: controller.canActivate ? onActivate : null,
              borderRadius: BorderRadius.circular(GameHudStyle.gap),
              child: Padding(
                padding: const EdgeInsets.all(GameHudStyle.gap),
                child: isKeyboard
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            style?.icon ?? Icons.bolt,
                            size: GameHudStyle.healthHeight,
                            color: controller.isUsing
                                ? style?.color
                                : GameHudStyle.foreground,
                          ),
                          const SizedBox(width: GameHudStyle.gap),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: GameHudStyle.foreground,
                                    fontSize: GameHudStyle.labelFontSize,
                                  ),
                                ),
                                if (controller.isUsing && cooldown > 0)
                                  Text(
                                    context.l10n.secondsShort(cooldown),
                                    style: const TextStyle(
                                      color: GameHudStyle.foreground,
                                      fontSize: GameHudStyle.guideFontSize,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: GameHudStyle.abilitySize - GameHudStyle.gap * 2,
                        height: GameHudStyle.abilitySize - GameHudStyle.gap * 2,
                        child: Center(
                          child: label == null
                              ? Icon(
                                  style?.icon ?? Icons.bolt,
                                  color: style?.color,
                                )
                              : Text(
                                  label,
                                  style: const TextStyle(
                                    color: GameHudStyle.foreground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
