import 'package:flame/components.dart';
import 'package:gunwave/views/game/abilities/ability_context.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';
import 'package:gunwave/views/game/components/character.dart';

class FakeCombatant implements Combatant {
  int hp = 100;
  Vector2 center = Vector2.zero();
  @override
  final effects = StatusEffectController();
  @override
  int get health => hp;
  @override
  int get maxHealth => 100;
  @override
  int get attackPower => 20;
  @override
  bool get isAlive => hp > 0;
  @override
  Vector2 get combatCenter => center;
  @override
  bool takeDamage(Damage damage) {
    hp = (hp - effects.incomingDamage(damage.amount)).clamp(0, maxHealth);
    return true;
  }

  @override
  void heal(int amount) => hp = (hp + amount).clamp(0, maxHealth);
}

class FakeContext implements AbilityContext {
  @override
  final FakeCombatant caster = FakeCombatant();
  @override
  Iterable<Combatant> get combatants sync* {
    yield caster;
    yield* targets;
  }

  bool blocked = false;
  final targets = <Combatant>[];
  final projectiles = <({int damage, double range, bool piercing})>[];
  double? lastRadius;
  ({double distance, double duration})? lastDash;
  @override
  bool get isBlocked => blocked;
  @override
  Iterable<Combatant> targetsWithin(double radius) {
    lastRadius = radius;
    return targets.where((t) =>
        t.isAlive && t.combatCenter.distanceTo(caster.combatCenter) <= radius);
  }

  @override
  bool dash({required double distance, required double duration}) {
    lastDash = (distance: distance, duration: duration);
    return true;
  }

  @override
  void launchProjectile(
          {required int damage,
          required double range,
          required bool piercing}) =>
      projectiles.add((damage: damage, range: range, piercing: piercing));
  @override
  void showFeedback({required double radius}) {}
}

// Movement/combat tests do not load graphics or animation assets.
class TestCharacter extends Character {
  TestCharacter(super.character);
  dynamic state;
  @override
  dynamic get current => state;
  @override
  set current(dynamic value) => state = value;
}
