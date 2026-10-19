import 'package:gunwave/views/game/abilities/ability_context.dart';
import 'package:gunwave/views/game/abilities/ability_visual_style.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/components/ability_feedback.dart';
import 'package:gunwave/views/game/components/projectiles/ability_projectile.dart';
import 'package:gunwave/views/game/gunwave.dart';

/// Adapts the current Flame stage to the independently testable ability engine.
class GameAbilityContext implements AbilityContext {
  const GameAbilityContext(this.game);
  final Gunwave game;
  @override
  Combatant get caster => game.character;
  @override
  Iterable<Combatant> get combatants sync* {
    yield caster;
    yield* game.stage?.monsters ?? const <Combatant>[];
  }

  @override
  bool get isBlocked => !game.isLoaded || game.controlsBlocked || game.paused;
  @override
  Iterable<Combatant> targetsWithin(double radius) sync* {
    for (final monster in game.stage?.monsters ?? []) {
      if (monster.isAlive &&
          monster.combatCenter.distanceToSquared(caster.combatCenter) <=
              radius * radius) {
        yield monster;
      }
    }
  }

  @override
  bool dash({required double distance, required double duration}) =>
      game.character.startDash(distance: distance, duration: duration);
  @override
  void launchProjectile(
      {required int damage, required double range, required bool piercing}) {
    game.world.add(AbilityProjectile(
        origin: caster.combatCenter,
        direction: game.character.facingDirection,
        damage: damage,
        range: range,
        piercing: piercing,
        visualStyle:
            AbilityVisualStyle.forKey(game.gameCharacters.ability?.key ?? '') ??
                AbilityVisualStyle.flameBrand));
  }

  @override
  void showFeedback({required double radius}) {
    final style =
        AbilityVisualStyle.forKey(game.gameCharacters.ability?.key ?? '');
    if (style == null) return;
    _showFeedback(caster, style, radius);
    for (final monster in game.stage?.monsters ?? []) {
      if (monster.isAlive && monster.effects[style.key] != null) {
        _showFeedback(monster, style, game.character.hitbox.width / 2);
      }
    }
  }

  void _showFeedback(
      Combatant target, AbilityVisualStyle style, double radius) {
    for (final feedback in game.world.children.whereType<AbilityFeedback>()) {
      if (!feedback.isFinished &&
          identical(feedback.target, target) &&
          feedback.style == style) {
        feedback.refresh();
        return;
      }
    }
    game.world.add(AbilityFeedback(
        style: style,
        target: target,
        radius: radius,
        direction: game.character.facingDirection));
  }
}
