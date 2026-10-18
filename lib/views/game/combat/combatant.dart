import 'package:flame/components.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';

/// Identifies the cause of a hit for future resistance and feedback rules.
enum DamageSource { melee, monster, fire, ability }

/// An immutable damage request resolved by its recipient.
class Damage {
  const Damage(this.amount, {required this.source});
  final int amount;
  final DamageSource source;
}

/// The shared combat surface used by characters, monsters and abilities.
abstract interface class Combatant {
  int get health;
  int get maxHealth;
  int get attackPower;
  bool get isAlive;
  Vector2 get combatCenter;
  StatusEffectController get effects;
  bool takeDamage(Damage damage);
  void heal(int amount);
}
