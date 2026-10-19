import 'package:gunwave/views/game/combat/combatant.dart';

/// Supplies world operations without coupling ability logic to the Flame game.
abstract interface class AbilityContext {
  Combatant get caster;
  /// Includes the caster and targets so the HUD can observe persistent effects.
  Iterable<Combatant> get combatants;
  bool get isBlocked;
  Iterable<Combatant> targetsWithin(double radius);
  bool dash({required double distance, required double duration});
  void launchProjectile({
    required int damage,
    required double range,
    required bool piercing,
  });
  void showFeedback({required double radius});
}
